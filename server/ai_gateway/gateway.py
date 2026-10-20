"""
Scholon AI gateway (reference implementation, NOT load-tested).

Sits between the Flutter app and a self-hosted OpenAI-compatible model server
(llama.cpp `llama-server`, vLLM, etc.). It:
  * verifies the caller's Firebase ID token (no API keys on devices),
  * rate-limits per user and caps request size,
  * streams the upstream response (SSE) back to the app,
  * exposes /health for the app's availability indicator.

Run:  uvicorn gateway:app --host 0.0.0.0 --port 8080
Env:  UPSTREAM_URL (default http://model:8000), FIREBASE_PROJECT_ID, RATE_PER_MIN (default 12)
"""
import os, time, collections
import httpx
from fastapi import FastAPI, Header, HTTPException, Request
from fastapi.responses import StreamingResponse, JSONResponse
from google.oauth2 import id_token
from google.auth.transport import requests as g_requests

UPSTREAM = os.environ.get("UPSTREAM_URL", "http://model:8000")
PROJECT = os.environ["FIREBASE_PROJECT_ID"]
RATE = int(os.environ.get("RATE_PER_MIN", "12"))
MAX_BODY = 64_000          # bytes
MAX_TOKENS = 1200

app = FastAPI(title="Scholon AI Gateway")
_hits: dict[str, collections.deque] = collections.defaultdict(collections.deque)
_req = g_requests.Request()


def verify(authorization: str | None) -> str:
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(401, "Missing token")
    try:
        claims = id_token.verify_firebase_token(authorization[7:], _req, audience=PROJECT)
    except Exception:
        raise HTTPException(401, "Invalid token")
    return claims["uid"] if "uid" in claims else claims["sub"]


def limited(uid: str) -> bool:
    now = time.time()
    q = _hits[uid]
    while q and now - q[0] > 60:
        q.popleft()
    if len(q) >= RATE:
        return True
    q.append(now)
    return False


@app.get("/health")
async def health():
    try:
        async with httpx.AsyncClient(timeout=3) as c:
            r = await c.get(f"{UPSTREAM}/health")
        return {"ok": r.status_code == 200}
    except Exception:
        return JSONResponse({"ok": False}, status_code=503)


@app.post("/v1/chat/completions")
async def chat(request: Request, authorization: str | None = Header(default=None)):
    uid = verify(authorization)
    if limited(uid):
        raise HTTPException(429, "Too many requests")
    raw = await request.body()
    if len(raw) > MAX_BODY:
        raise HTTPException(413, "Request too large")
    body = await request.json()
    body["stream"] = True
    body["max_tokens"] = min(int(body.get("max_tokens", 800)), MAX_TOKENS)
    body.pop("user", None)  # never forward identifiers to the model server

    async def relay():
        async with httpx.AsyncClient(timeout=httpx.Timeout(120, connect=5)) as c:
            async with c.stream("POST", f"{UPSTREAM}/v1/chat/completions", json=body) as r:
                if r.status_code != 200:
                    yield f'data: {{"error": {r.status_code}}}\n\n'.encode()
                    return
                async for chunk in r.aiter_raw():
                    yield chunk

    return StreamingResponse(relay(), media_type="text/event-stream")
