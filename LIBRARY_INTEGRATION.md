# Internet Archive integration

Endpoints used (confirmed from public documentation and client libraries; re-check archive.org/developers):
* `GET https://archive.org/advancedsearch.php?q=<lucene>&fl[]=...&rows=&page=&sort[]=&output=json`
* `GET https://archive.org/metadata/{identifier}`
* Item page: `https://archive.org/details/{identifier}` (we link out; we never call borrow/download endpoints).

Behaviour: identifying User-Agent, 400 ms minimum gap, retry with back-off on 429/5xx (honours Retry-After),
12 s timeout, memory cache (10 min) for search, disk cache (24 h) for item metadata, stale fallback offline.
Access labels come only from metadata: open licence (licenseurl public-domain/CC), borrow/restricted
(lending collections or access-restricted flag), otherwise "view on Internet Archive".
Not done: embedded reader, full-text analysis of public-domain books for AI, reading progress.
