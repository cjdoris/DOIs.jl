module DOIs

import HTTP
import URIs

export doi_resolve, doi_citation, doi_bibtex, doi_rdf_xml, doi_turtle, doi_citeproc_json, doi_ris

"""
    doi_url(doi)

The URL where the given DOI can be resolved.

If `doi` is already a URL, it is assumed to be a DOI URL and is returned directly.
"""
function doi_url(doi::AbstractString)
    doi = convert(String, doi)
    if startswith(doi, "https://") || startswith(doi, "http://")
        doi
    else
        "https://dx.doi.org/" * URIs.escapepath(doi)
    end
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

"""
    doi_citation(doi; style=nothing, locale=nothing)

A formatted text citation for the given DOI.

These use the Citation Style Language processor.
See the [CSL style repository](https://github.com/citation-style-language/styles)
for allowed `style`s.
See the [CSL locale repository](https://github.com/citation-style-language/locales)
for allowed `locale`s.
"""
function doi_citation(doi::AbstractString; style::Union{Nothing,AbstractString}=nothing, locale::Union{Nothing,AbstractString}=nothing)
    accept_parts = ["text/x-bibliography"]
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
