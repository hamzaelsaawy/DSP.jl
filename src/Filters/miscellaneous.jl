
#
# linearize a gain
#
linear_gain(x::Real) = x
linear_gain(x::Gain) = uconvertp(NoUnits, x)
linear_gain(x::Level) = linear_gain(linear(x))
linear_gain(x::DimensionlessQuantity) = uconvert(NoUnits, x)
linear_gain(x::Unitful.Power) = linear_gain(x/1u"W")
linear_gain(x::Unitful.Voltage) = linear_gain(x/1u"V")
linear_gain(x) = ArgumentError("$(x)::$(typeof(x)) is not a valid gain.")
