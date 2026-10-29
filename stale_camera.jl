# Reads a text plot's camera, resizes the scene, reads the camera again straight away,
# and checks whether the plot picked up the new camera. Makie stamps camera changes with
# `time()` and drops a change whose stamp equals the previous one, so when both reads
# fall within one tick of `time()` the plot keeps the old camera.
using CairoMakie

function stale_once()
    scene = Scene(size = (600, 450), camera = campixel!)
    label = text!(scene, Point2f(100, 100), text = "label")
    label.attributes[:projectionview][]
    resize!(scene, 400, 300)
    plot_camera = Makie.Mat4f(label.attributes[:projectionview][])
    scene_camera = Makie.get_projectionview(scene.compute, :data)
    return plot_camera != scene_camera
end

stale_count(n) = count(_ -> stale_once(), 1:n)

println("Makie $(pkgversion(Makie)), Julia $VERSION on $(Sys.KERNEL)")
stale_once()  # compile first
println("time() trigger:  $(stale_count(1000)) of 1000 plots kept the old camera")

src = read(joinpath(pkgdir(Makie), "src", "camera", "camera.jl"), String)
i = first(findfirst("function add_camera_computation!", src))
fsrc = src[i:prevind(src, Meta.parse(src, i)[2])]
old = "map!((a, b, c) -> time(), graph, [:view, :projection, :viewport], :camera_trigger)"
occursin(old, fsrc) || error("camera_trigger line not found in this Makie version")
Makie.eval(:(const CAMERA_TRIGGER_COUNTER = Threads.Atomic{UInt64}(0)))
Makie.eval(Meta.parse(replace(fsrc, old => "map!((a, b, c) -> Threads.atomic_add!(CAMERA_TRIGGER_COUNTER, UInt64(1)), graph, [:view, :projection, :viewport], :camera_trigger)")))
println("counter trigger: $(stale_count(1000)) of 1000 plots kept the old camera")
