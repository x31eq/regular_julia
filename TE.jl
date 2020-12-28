module TE

using LinearAlgebra

export limit, rms_of_matrix, te_complexity, optimal_badness, cangwu
export best_et, get_equal_temperaments, limited_mappings

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

function optimal_badness(M, limit)
    n_primes = length(limit)
    M = M ./ limit
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

function get_equal_temperaments(plimit, ek, n_results)
    # Goofy but reliable rule for nonoctave limits
    plimit = plimit ./ plimit[1]

    badness(m) = cangwu(ek, m, plimit)

    # Quick calculation to determine bmax
    results = [prime_et(plimit, 1)]
    for i ∈ 2:(n_results + size(plimit, 2))
        results = vcat(results, [prime_et(plimit, i)])
    end
    sort!(results, by=badness)
    bmax = badness(results[n_results])

    n_notes = 1
    results = Int64[]
    while n_notes ≤ bmax/ek
        mappings = limited_mappings(n_notes, ek, bmax, plimit)
        if mappings ≠ []
            if results == []
                results = mappings
            else
                results = vcat(results, mappings)
            end
            sort!(results, by=badness)
            if length(results) ≥ n_results
                results = results[1:n_results]
                bmax = min(bmax, badness(results[end]))
            end
        end
        n_notes += 1
    end
    results
end

function best_et(plimit, n_notes)
    pet = prime_et(plimit, n_notes)
    cap = optimal_badness(pet, plimit)
    mappings = limited_mappings(n_notes, 0.0, cap, plimit)
    if mappings == []
        pet
    else
        sort!(mappings, by=m -> optimal_badness(m, plimit))
        mappings[1]
    end
end

prime_et(plimit, n_notes) = [Int64(round(n_notes * x)) for x in plimit]

function limited_mappings(n_notes, ek, bmax, plimit)
    cap = bmax^2 * length(plimit) / plimit[1]^2
    # convert from ek form to ε² form
    ε² = ek^2 / (1.0 + ek^2)

    function more_limited_mappings(mapping, tot, tot²)
        i = length(mapping)
        if i == length(plimit)
            return [mapping]
        end
        weighted_size = mapping[end] / plimit[i]
        tot += weighted_size
        tot² += weighted_size^2
        λ = 1 - ε²

        result = Array{Array{Int64,2},1}()
        toti = tot * λ / (i + ε²)
        error² = tot² - tot * toti
        if error² ≥ cap
            return result
        end
        target = plimit[i + 1]
        deficit = √((i+1) * (cap-error²) / (i + ε²))
        xmin = target * (toti - deficit)
        xmax = target * (toti + deficit)

        result = Array{Array{Int64,2},1}()
        for guess in intrange(xmin, xmax)
            more = more_limited_mappings(hcat(mapping, [guess]), tot, tot²)
            result = vcat(result, more)
        end
        result
    end

    more_limited_mappings(Int64[n_notes], 0.0, 0.0)
end

function intrange(x, y)
    [x for x in Int64(ceil(x)):Int64(floor(y))]
end

end
