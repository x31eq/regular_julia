module TE

using LinearAlgebra

export limit, rms_of_matrix, te_complexity, optimal_badness, cangwu

const primes = [2 3 5 7 11 13 17 19 23 29 31]

limit(n) = log2.(transpose(primes[primes .≤ n]))

rms_of_matrix(W) = prod(svdvals(W / √size(W, 2)))

function optimal_badness(M)
    n_primes = size(M, 2)
    MV = repeat(sum(M, dims=2), 1, n_primes)
    rms_of_matrix(M - MV / n_primes)
end

function cangwu(ε, M)
    n_primes = size(M, 2)
    MV = repeat(sum(M, dims=2), 1, n_primes)
    rms_of_matrix(M - (1 - ε) / n_primes * MV)
end

function cangwu(ε, M, limit)
    n_primes = length(limit)
    M = M ./ limit
    MV = repeat(sum(M, dims=2), 1, n_primes)
    rms_of_matrix(M - (1 - ε) / n_primes * MV)
end

te_complexity(M, limit) = rms_of_matrix(M ./ limit)

end
