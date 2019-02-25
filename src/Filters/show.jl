#
# printing for various objects
#

#
# filter coefficients
#

# here be the globals :/
mutable struct FilterPrintSettings
    # bit of a hack: Polynomial's printing just ... prints, so capture it here
    buffer::IOBuffer
    var::Symbol
    compact::Bool
end

const _fps = FilterPrintSettings(IOBuffer(sizehint=64), :z, true)

function show_filters_compact()
    global _fps
    _fps.compact = true
    return nothing
end

function show_filters_uncompact()
    global _fps
    _fps.compact = false
    return nothing
end

function show_filters_discrete()
    global _fps
    _fps.var = :z
    return nothing
end

function show_filters_continuous()
    global _fps
    _fps.var = :s
    return nothing
end

function repr_poly!(p::Poly, offset::Int, mimetype::MIME, fps::FilterPrintSettings=_fps)
    io = fps.buffer
    seekstart(io)
    printpoly(IOContext(io, :compact=>fps.compact), p, mimetype,
            descending_powers=true, offset=offset)
    len = position(io)
    seekstart(io)
    s = String(read(io, len))

    return s
end

function Base.show(io::IO, mimetype::MIME"text/latex", f::FilterCoefficients)
    # make polynomial ratio vs using coefb/a because of reversal in coeffs
    fp = PolynomialRatio(f)
    B = Poly(fp.b.a, _fps.var)
    A = Poly(fp.a.a, _fps.var)

    offset = (_fps.var == :z) ? -maximum(degree.([B, A])) : 0

    Bstr = repr_poly!(B, offset, mimetype)
    Astr = repr_poly!(A, offset, mimetype)

    print(io, "\$\\dfrac{$(Bstr)}{$(Astr)}\$")
end

function Base.show(io::IO, mimetype::MIME"text/html", f::FilterCoefficients)
    # make polynomial ratio vs using coefb/a because of reversal in coeffs
    fp = PolynomialRatio(f)
    B = Poly(fp.b.a, _fps.var)
    A = Poly(fp.a.a, _fps.var)

    offset = (_fps.var == :z) ? -maximum(degree.([B, A])) : 0

    Bstr = repr_poly!(B, offset, mimetype)
    Astr = repr_poly!(A, offset, mimetype)

    spanline = "<span style=\"border-top: solid 0.1em; display:block;\">"
    div_tag = "<div style=\"display: inline-block; text-align:center\">"
    print(io, "$(div_tag)" *
            "$(Bstr)</br>" *
            "$(spanline)</span>" *
            "$(Astr)" *
            "</div>")
end

function Base.show(io::IO, mimetype::MIME"text/plain", f::FilterCoefficients)
    # make polynomial ratio vs using coefb/a because of reversal in coeffs
    fp = PolynomialRatio(f)
    B = Poly(fp.b.a, _fps.var)
    A = Poly(fp.a.a, _fps.var)

    offset = (_fps.var == :z) ? -maximum(degree.([B, A])) : 0

    Bstr = repr_poly!(B, offset, mimetype)
    Astr = repr_poly!(A, offset, mimetype)
    total_len = max(length(Bstr), length(Astr)) + 2

    Bstrpad = center_in(Bstr, total_len)
    Astrpad = center_in(Astr, total_len)
    line = repeat("-", total_len)

    println(io, Bstrpad)
    println(io, line)
    println(io, Astrpad)
end

#
# various printing utility functions
#

function center_in(s::String, total_len::Int; p::Char=' ')
    (length(s) ≥ total_len) && return s

    slen = length(s)
    return repeat(p, floor(Int, (total_len - slen)/2)) * s *
            repeat(" ", ceil(Int, (total_len - slen)/2))
end
