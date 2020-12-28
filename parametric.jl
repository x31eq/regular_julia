push!(LOAD_PATH, ".")
using TE

const marvel = [22 35 51 62 76; 31 49 72 87 107; 41 65 95 115 142]
const magic = [22 35 51 62 76; 41 65 95 115 142]
const limit11 = limit(11)

println("Magic complexity ", rms_of_matrix(magic ./ limit11))
println("Marvel complexity ", rms_of_matrix(marvel ./ limit11))

println("Magic badness ", optimal_badness(magic ./ limit11))
println("Marvel badness ", optimal_badness(marvel ./ limit11))

println("Magic 1-cent badness ", cangwu(1/1200, magic ./ limit11))
println("Marvel 1-cent badness ", cangwu(1/1200, marvel ./ limit11))

println("Magic complexity ", te_complexity(magic, limit11))
println("Marvel complexity ", te_complexity(marvel, limit11))

println("Magic badness ", cangwu(0, magic, limit11))
println("Marvel badness ", cangwu(0, marvel, limit11))
println("Magic 1-cent badness ", cangwu(1/1200, magic, limit11))
println("Marvel 1-cent badness ", cangwu(1/1200, marvel, limit11))

let plimit = limit(5)
    mappings = limited_mappings(12, 0.01, 0.3, plimit)
    sort!(mappings, by=m -> cangwu(1/1200, m, plimit))
    println(mappings)
end
let plimit = limit(11)
    mappings = limited_mappings(31, 0.01, 0.35, plimit)
    sort!(mappings, by=m -> cangwu(1/1200, m, plimit))
    println(mappings)
end
