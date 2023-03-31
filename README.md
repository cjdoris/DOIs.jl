# DOIs.jl

Julia library for querying Digital Object Identifiers (DOIs) from https://doi.org.

## Install

This package is not registered, so do:
```
pkg> add https://github.com/cjdoris/DOIs.jl
```

## API

See the docstrings for more information.
- `doi_resolve(doi)` resolve the URL for the given DOI.
- `doi_citation(doi; style, locale)` a formatted text citation.
- `doi_bibtex(doi)` a BibTeX citation.
- `doi_rdf_xml(doi)` a RDF XML citation.
- `doi_turtle(doi)` a RDF Turtle citation.
- `doi_citeproc_json(doi)` a Citeproc JSON citation.
- `doi_ris(doi)` a Research Info Systems (RIS) citation.
