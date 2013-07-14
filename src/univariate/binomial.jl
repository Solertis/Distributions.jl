immutable Binomial <: DiscreteUnivariateDistribution
    size::Int
    prob::Float64
    function Binomial(n::Real, p::Real)
    	if n <= 0
	    	error("size must be positive")
	    else
	    	if 0.0 <= p <= 1.0
	    		new(int(n), float64(p))
	    	else
	    		error("prob must be in [0, 1]")
			end
	    end
	end
end

Binomial(size::Integer) = Binomial(size, 0.5)
Binomial() = Binomial(1, 0.5)

min(d::Binomial) = 0
max(d::Binomial) = d.size

@_jl_dist_2p Binomial binom

function entropy(d::Binomial)
	n, p = d.size, d.prob
	return 0.5 * log(2.0 * pi * e * n * p * (1.0 - p))
end

insupport(d::Binomial, x::Number) = isinteger(x) && 0 <= x <= d.size

kurtosis(d::Binomial) = (1.0 - 6.0 * d.prob * (1.0 - d.prob)) / var(d)

mean(d::Binomial) = d.size * d.prob

median(d::Binomial) = iround(d.size * d.prob)

# TODO: May need to subtract 1 sometimes
modes(d::Binomial) = iround((d.size + 1.0) * d.prob)

function mgf(d::Binomial, t::Real)
	n, p = d.size, d.prob
	return (1.0 - p + p * exp(t))^n
end

function cf(d::Binomial, t::Real)
	n, p = d.size, d.prob
	return (1.0 - p + p * exp(im * t))^n
end

modes(d::Binomial) = iround([d.size * d.prob])

# TODO: rand() is totally screwed up

skewness(d::Binomial) = (1.0 - 2.0 * d.prob) / std(d)

var(d::Binomial) = d.size * d.prob * (1.0 - d.prob)

function fit_mle{T<:Real}(::Type{Binomial}, n::Integer, x::Array{T})
    # a series of experiments, each experiment has n trials
    # x[i] is the number of successes in the i-th experiment

    sx = 0.
    for xi in x
    	if xi < 0 || xi > n
    		error("Each element in x must be in [0, n].")
    	end
    	sx += xi
    end

    Binomial(int(n), sx / (n * length(x)))
end

fit(::Type{Binomial}, n::Integer, x::Array) = fit_mle(Binomial, n, x)

