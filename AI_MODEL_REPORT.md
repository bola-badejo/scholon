# AI model selection report (INCOMPLETE BY DESIGN)

No benchmark was run and no model was downloaded in this environment. Items below are either
an evaluation plan or marked "from memory - verify". Do not treat them as measurements.

## Candidates to evaluate
Qwen (instruct, 3B-14B), Gemma (instruct), Llama-family instruct. Licence terms differ by model AND
size (e.g. some Qwen sizes use Apache-2.0, others a custom licence; Gemma has its own terms of use
with use restrictions; Llama has a community licence with conditions). **From memory - read the
model card and licence for the exact version before shipping.**

## Rules of thumb (estimates, not measurements)
* 4-bit quantised weights need roughly 0.5-0.7 GB RAM per billion parameters plus KV cache.
* A 3B model at 4-bit is plausible on recent phones; 7-14B needs a server GPU or a desktop.

## Required evaluation (do this before choosing)
1. Build a 200-question Scholon eval set from the real curriculum (maths, science, English) with
   reference answers; add 50 adversarial cases (prompt injection, off-topic, request to cheat).
2. Score each candidate on: correctness, step-by-step teaching quality, refusal to fabricate citations,
   level adaptation, and speed (time to first token, tokens/s) on the target hardware.
3. Record: exact model + revision, quantisation, memory, startup time, concurrency limit.
4. Pick the smallest model that passes; keep a larger hosted model for hard questions.

## Layers
A on-device: not implemented (runtime options to evaluate: llama.cpp bindings, MediaPipe LLM Inference,
MLC, WebGPU). B hosted: `server/ai_gateway` (reference, untested). C offline: implemented, labelled as lookup.
