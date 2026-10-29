# test-makie-timer

Repro for [MakieOrg/Makie.jl#5860](https://github.com/MakieOrg/Makie.jl/issues/5860). CI runs two scripts on `windows-latest` and `ubuntu-latest` with Julia 1.13:

- `time_resolution.jl` measures how finely `time()` moves.
- `label_repro.jl` renders the same figure with a rotated `Label` 100 times and counts the distinct images, first with Makie's `camera_trigger = time()`, then with `camera_trigger` patched to a counter. The distinct images are uploaded as artifacts.
