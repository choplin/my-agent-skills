# `code.performance-regression`

## Objective

Find material latency, throughput, memory, I/O, or resource-lifetime regressions
introduced or materially worsened by the code change.

## Required inputs

- the diff and expected workload shape
- hot-path, data-volume, concurrency, and resource-lifetime context
- benchmarks, profiles, checks, or code paths that establish scale and frequency

## Checks

- Compare algorithmic work and allocation growth before and after the change.
- Find repeated queries, network calls, serialization, filesystem work, or other
  I/O added inside loops or frequently invoked paths.
- Check for unbounded collections, retained resources, missing cleanup, and work
  that grows with user-controlled input.
- Inspect blocking behavior, lock scope, retry loops, concurrency limits, and
  backpressure on changed paths.
- Identify the workload size, frequency, or environment at which the consequence
  becomes material.

## Non-goals

- Do not report micro-optimizations without material impact.
- Do not assume a path is hot without evidence from its callers or workload.
- Do not prefer clever code over clear code for hypothetical speed.

## Severity guidance

Use blocker when ordinary supported load makes the system unavailable or loses
work. Use major for a material regression on a realistic workload and minor for
a bounded but measurable inefficiency worth fixing.
