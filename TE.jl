module TE

using LinearAlgebra

export limit, rms_of_matrix, te_complexity, optimal_badness, cangwu
export get_equal_temperaments, get_linear_temperaments
export best_et, limited_mappings

const MappingArray = Array{Int64,2}
const TuningArray = Array{Float64,2}
const MappingList = Array{MappingArray,1}

limit(n::Int64)::TuningArray = log2.(transpose(primes(n)))

#
# Calculations on known mappings
#

rms_of_matrix(W::TuningArray)::Float64 = prod(svdvals(W / √size(W, 2)))

function optimal_badness(M::TuningArray)::Float64
    n_primes = size(M, 2)
    MV = repeat(sum(M, dims=2), 1, n_primes)
    rms_of_matrix(M - MV / n_primes)
end

function optimal_badness(M::MappingArray, limit::TuningArray)::Float64
    n_primes = length(limit)
    M = M ./ limit
    MV = repeat(sum(M, dims=2), 1, n_primes)
    rms_of_matrix(M - MV / n_primes)
end

function cangwu(ε::Float64, M::TuningArray)::Float64
    n_primes = size(M, 2)
    MV = repeat(sum(M, dims=2), 1, n_primes)
    rms_of_matrix(M - (1 - ε) / n_primes * MV)
end

function cangwu(ε::Float64, M::MappingArray, limit::TuningArray)::Float64
    n_primes = length(limit)
    M = M ./ limit
    MV = repeat(sum(M, dims=2), 1, n_primes)
    rms_of_matrix(M - (1 - ε) / n_primes * MV)
end

te_complexity(M::MappingArray, limit::TuningArray) = rms_of_matrix(M ./ limit)

#
# Equal temperament finding
#

function get_equal_temperaments(
        plimit::TuningArray, ek::Float64, n_results::Int64)::MappingList
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
    results = MappingList()
    while n_notes ≤ bmax/ek
        mappings = limited_mappings(n_notes, ek, bmax, plimit)
        if mappings ≠ []
            results = vcat(results, mappings)
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

function best_et(plimit::TuningArray, n_notes::Int64)::MappingArray
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

prime_et(plimit::TuningArray, n_notes::Int64)::MappingArray =
    [Int64(round(n_notes * x)) for x in plimit]

function limited_mappings(
        n_notes::Int64, ek::Float64, bmax::Float64, plimit::TuningArray,
        )::MappingList
    cap = bmax^2 * length(plimit) / plimit[1]^2
    # convert from ek form to ε² form
    ε² = ek^2 / (1.0 + ek^2)

    function more_limited_mappings(
            mapping::MappingArray, tot::Float64, tot²::Float64)::MappingList
        i = length(mapping)
        if i == length(plimit)
            return [mapping]
        end
        weighted_size = mapping[end] / plimit[i]
        tot += weighted_size
        tot² += weighted_size^2
        λ = 1 - ε²

        result = MappingList()
        toti = tot * λ / (i + ε²)
        error² = tot² - tot * toti
        if error² ≥ cap
            return result
        end
        target = plimit[i + 1]
        deficit = √((i+1) * (cap-error²) / (i + ε²))
        xmin = target * (toti - deficit)
        xmax = target * (toti + deficit)

        result = MappingList()
        for guess in intrange(xmin, xmax)
            more = more_limited_mappings(hcat(mapping, [guess]), tot, tot²)
            result = vcat(result, more)
        end
        result
    end

    more_limited_mappings(reshape([n_notes], (1, 1)), 0.0, 0.0)
end

#
# Regular temperament finding
#

function get_linear_temperaments(
        plimit::TuningArray, ek::Float64,
        ets::MappingList, n_results::Int64)::MappingList
    rts = MappingList()
    for i ∈ 1:(length(ets) - 1)
        for j ∈ (i+1):length(ets)
            push!(rts, vcat(ets[i], ets[j]))
        end
    end
    badness(m) = cangwu(ek, m, plimit)
    sort!(rts, by=badness)
    if length(rts) > n_results
        rts[1:n_results]
    else
        rts
    end
end

#
# Utilities
#

# Based on https://riptutorial.com/julia-lang/example/13313/sieve-of-eratosthenes
function primes(n::Int64)
    P = Int64[]
    for i ∈ 2:n
        if !any(x -> i % x == 0, P)
            push!(P, i)
        end
    end
    P
end

intrange(x::Float64, y::Float64)::Array{Int64,1} =
    [x for x in Int64(ceil(x)):Int64(floor(y))]

end
