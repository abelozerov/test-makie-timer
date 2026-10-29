# Renders the same figure many times and counts how many different images come out.
# With Makie's `camera_trigger = time()` a coarse clock lets some renders keep the
# camera of the default 600x450 figure, so the rotated label comes out shrunk and moved.
using CairoMakie

function render()
    f = Figure()
    Axis(f[1, 1], width = 200, height = 200)
    Label(f[1, 0], "Rotated label", rotation = pi / 2)
    resize_to_layout!(f)
    return colorbuffer(f)
end

function report(tag, n)
    images = [render() for _ in 1:n]
    distinct = unique(images)
    println("$tag: $(length(distinct)) distinct image(s) in $n renders, counts $([count(==(d), images) for d in distinct])")
    for (i, img) in enumerate(distinct)
        save(joinpath("out", "$(tag)_$i.png"), img)
    end
end

mkpath("out")
println("Makie $(pkgversion(Makie)), CairoMakie $(pkgversion(CairoMakie)), Julia $VERSION on $(Sys.KERNEL)")
render()  # compile first
report("time_trigger", 100)

# Same renders with `camera_trigger` taken from a counter instead of `time()`
src = read(joinpath(pkgdir(Makie), "src", "camera", "camera.jl"), String)
i = first(findfirst("function add_camera_computation!", src))
fsrc = src[i:prevind(src, Meta.parse(src, i)[2])]
old = "map!((a, b, c) -> time(), graph, [:view, :projection, :viewport], :camera_trigger)"
occursin(old, fsrc) || error("camera_trigger line not found in this Makie version")
Makie.eval(:(const CAMERA_TRIGGER_COUNTER = Threads.Atomic{UInt64}(0)))
Makie.eval(Meta.parse(replace(fsrc, old => "map!((a, b, c) -> Threads.atomic_add!(CAMERA_TRIGGER_COUNTER, UInt64(1)), graph, [:view, :projection, :viewport], :camera_trigger)")))
report("counter_trigger", 100)
