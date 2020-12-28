module TE

using LinearAlgebra

export limit, rms_of_matrix, te_complexity, optimal_badness, cangwu
export limited_mappings

const primes = [2 3 5 7 11 13 17 19 23 29 31]

limit(n) = log2.(transpose(primes[primes .≤ n]))

#
# Calculations on known mappings
#

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

#
# Equal temperament finding
#

function limited_mappings(n_notes, ek, bmax, plimit)
    cap = bmax^2 * length(plimit) / plimit[1]^2
    # convert from ek form to ε² form
    ε² = ek^2 / (1.0 + ek^2)

    function more_limited_mappings(mapping, tot, tot²)
        i = length(mapping)
        weighted_size = mapping[end] / plimit[i]
        tot += weighted_size
        tot² += weighted_size^2
        λ = 1 - ε²
        if i == length(plimit)
            return mapping
        end

        toti = tot * λ / (i + ε²)
        error² = tot² - tot * toti
        if error² ≥ cap
            return Int64[]
        end
        target = plimit[i + 1]
        deficit = √((i+1) * (cap-error²) / (i + ε²))
        xmin = target * (toti - deficit)
        xmax = target * (toti + deficit)

        result = Int64[]
        for guess in intrange(xmin, xmax)
            more = more_limited_mappings(vcat(mapping, [guess]), tot, tot²)
            if result == []
                result = more
            elseif more ≠ []
                result = hcat(result, more)
            end
        end
        result
    end

    mappings = more_limited_mappings(Int64[n_notes], 0.0, 0.0)
    [transpose(mappings[:,i]) for i ∈ 1:size(mappings, 2)]
end

function intrange(x, y)
    [x for x in Int64(ceil(x)):Int64(floor(y))]
end

end
