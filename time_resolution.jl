# How finely does `time()` move on this machine?
ts = [time() for _ in 1:100_000]
println("$(length(unique(ts))) distinct time() values in 100000 calls, spanning $(ts[end] - ts[1]) s")

t0 = time()
vals = Float64[]
while time() - t0 < 0.2
    push!(vals, time())
end
steps = diff(unique(vals))
println("over 0.2 s: $(length(steps) + 1) distinct values, steps between them (s): min $(minimum(steps)), max $(maximum(steps))")
