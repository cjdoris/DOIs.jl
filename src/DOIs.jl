module DOIs

import HTTP
import Preferences
import URIs

export doi_resolve, doi_citation, doi_bibtex, doi_rdf_xml, doi_turtle, doi_citeproc_json, doi_ris

_doi_url_prefix = Ref{Union{Nothing,String}}(nothing)

function doi_url_prefix()
    ans = _doi_url_prefix[]
    if ans === nothing
        ans = Preferences.@load_preference("url")::Union{String,Nothing}
        if ans === nothing
            ans = "https://dx.doi.org"
        end
        ans = string(rstrip(ans, '/'), "/")
        _doi_url_prefix[] = ans
    end
    ans
end

"""
    doi_url(doi)

The URL where the given DOI can be resolved.

The DOI can also be given as a full URL.

The URL prefix can be set with the `url` preference (`https://dx.doi.org` by default).
"""
function doi_url(doi::AbstractString)
    doi = convert(String, doi)
    prefix = doi_url_prefix()
    if (m = match(r"^https?://(.*)$", doi)) !== nothing
        rest = m.captures[1]
        if (m = match(r"^(dx\.)?doi\.org/(.*)$", rest)) !== nothing
            path = m.captures[2]
        else
            error("invalid DOI URL")
        end
    else
        path = URIs.escapepath(doi)
    end
    string(prefix, path)
end

"""
    doi_get(doi; ...)

Shorthand for `HTTP.get(doi_url(doi); ...)`.
"""
function doi_get(doi::AbstractString; kw...)
    HTTP.get(doi_url(doi); kw...)
end

"""
    doi_resolve(doi)

The URL that the given DOI resolves to.
"""
function doi_resolve(doi::AbstractString)
    res = doi_get(doi, redirect=false)
    300 ≤ res.status ≤ 399 || error("expecting a redirect but got status $(res.status)")
    ans = HTTP.header(res, "location")
    isempty(ans) && error("response does not include Location header")
    ans
end

"""
    doi_content(doi; ...)

The body of `doi_get(doi; ...)` as a string.
"""
function doi_content(doi::AbstractString; kw...)
    String(doi_get(doi; kw...).body)
end

"""
    doi_citation(doi, mime)

A citation for the given DOI in the given MIME format.

The `mime` is passed on as the `Accept` HTTP header.
See https://citation.crosscite.org/docs.html for acceptable values.

The one-argument functions `doi_citation`, `doi_bibtex`, `doi_rdf_xml`, `doi_turtle`,
`doi_citeproc_json` and `doi_ris` get the citation in a particular format.
"""
function doi_citation(doi::AbstractString, mime::AbstractString)
    doi_content(doi; headers=["Accept" => mime])
end

const _default_csl_style = Ref{Union{Nothing,Some{Union{Nothing,String}}}}(nothing)
const _default_csl_locale = Ref{Union{Nothing,Some{Union{Nothing,String}}}}(nothing)

function _get_default(ref, var, val)
    if val !== nothing
        val
    else
        ans = ref[]
        if ans === nothing
            ans = Preferences.@load_preference(var)::Union{String,Nothing}
            ref[] = Some{Union{Nothing,String}}(ans)
        else
            ans = something(ans)
        end
        ans
    end
end

csl_style(value) = _get_default(_default_csl_style, "csl_style", value)
csl_locale(value) = _get_default(_default_csl_locale, "csl_locale", value)

"""
    doi_citation(doi; style=nothing, locale=nothing)

A formatted text citation for the given DOI.

These use the Citation Style Language processor.
See the [CSL style repository](https://github.com/citation-style-language/styles)
for allowed `style`s.
See the [CSL locale repository](https://github.com/citation-style-language/locales)
for allowed `locale`s.

The default style can be set with the `csl_style` preference and the default locale can be
set with the `csl_locale` preference.
"""
function doi_citation(doi::AbstractString; style::Union{Nothing,AbstractString}=nothing, locale::Union{Nothing,AbstractString}=nothing)
    accept_parts = ["text/x-bibliography"]
    style = csl_style(style)
    locale = csl_locale(locale)
    style !== nothing && push!(accept_parts, "style=$style")
    locale !== nothing && push!(accept_parts, "locale=$locale")
    doi_citation(doi, join(accept_parts, "; "))
end

"""
    doi_bibtex(doi)

Get a citation in BibTeX format.
"""
function doi_bibtex(doi::AbstractString)
    doi_citation(doi, "application/x-bibtex")
end

"""
    doi_rdf_xml(doi)

Get a citation in RDF XML format.
"""
function doi_rdf_xml(doi::AbstractString)
    doi_citation(doi, "application/rdf+xml")
end

"""
    doi_turtle(doi)

Get a citation in RDF Turtle format.
"""
function doi_turtle(doi::AbstractString)
    doi_citation(doi, "text/turtle")
end

"""
    doi_citeproc_json(doi)

Get a citation in Citeproc JSON format.
"""
function doi_citeproc_json(doi::AbstractString)
    doi_citation(doi, "application/vnd.citationstyles.csl+json")
end

"""
    doi_ris(doi)

Get a citation in Research Info Systems (RIS) format.
"""
function doi_ris(doi::AbstractString)
    doi_citation(doi, "application/x-research-info-systems")
end

end # module DOIs
