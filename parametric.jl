push!(LOAD_PATH, ".")
using TE

marvel = [22 35 51 62 76; 31 49 72 87 107; 41 65 95 115 142]
magic = [22 35 51 62 76; 41 65 95 115 142]
limit11 = TE.limit(11)

println("Magic complexity ", TE.rms_of_matrix(magic ./ limit11))
println("Marvel complexity ", TE.rms_of_matrix(marvel ./ limit11))

println("Magic badness ", TE.optimal_badness(magic ./ limit11))
println("Marvel badness ", TE.optimal_badness(marvel ./ limit11))

println("Magic 1-cent badness ", TE.cangwu(1/1200, magic ./ limit11))
println("Marvel 1-cent badness ", TE.cangwu(1/1200, marvel ./ limit11))

println("Magic complexity ", TE.te_complexity(magic, limit11))
println("Marvel complexity ", TE.te_complexity(marvel, limit11))

println("Magic badness ", TE.cangwu(0, magic, limit11))
println("Marvel badness ", TE.cangwu(0, marvel, limit11))
println("Magic 1-cent badness ", TE.cangwu(1/1200, magic, limit11))
println("Marvel 1-cent badness ", TE.cangwu(1/1200, marvel, limit11))
