module TE

include("te.jl")

end

marvel = [22 35 51 62 76; 31 49 72 87 107; 41 65 95 115 142]
magic = [22 35 51 62 76; 41 65 95 115 142]

println("Magic complexity ", TE.rms_of_matrix(magic ./ TE.limit11))
println("Marvel complexity ", TE.rms_of_matrix(marvel ./ TE.limit11))

println("Magic badness ", TE.optimal_badness(magic ./ TE.limit11))
println("Marvel badness ", TE.optimal_badness(marvel ./ TE.limit11))

println("Magic 1-cent badness ", TE.cangwu(1/1200, magic ./ TE.limit11))
println("Marvel 1-cent badness ", TE.cangwu(1/1200, marvel ./ TE.limit11))

println("Magic complexity ", TE.te_complexity(magic, TE.limit11))
println("Marvel complexity ", TE.te_complexity(marvel, TE.limit11))

println("Magic badness ", TE.cangwu(0, magic, TE.limit11))
println("Marvel badness ", TE.cangwu(0, marvel, TE.limit11))
println("Magic 1-cent badness ", TE.cangwu(1/1200, magic, TE.limit11))
println("Marvel 1-cent badness ", TE.cangwu(1/1200, marvel, TE.limit11))
