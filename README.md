# DOIs.jl

Julia library for querying Digital Object Identifiers (DOIs) from https://doi.org.

## Install

This package is not registered, so do:
```
pkg> add https://github.com/cjdoris/DOIs.jl
```

## Example
```julia
julia> doi_resolve("10.48550/arXiv.1706.03762") |> println
https://arxiv.org/abs/1706.03762

julia> doi_citation("10.48550/arXiv.1706.03762") |> println
Vaswani, A., Shazeer, N., Parmar, N., Uszkoreit, J., Jones, L., Gomez, A. N., Kaiser, L., &amp; Polosukhin, I. (2017). <i>Attention Is All You Need</i> (Version 5). arXiv. https://doi.org/10.48550/ARXIV.1706.03762

julia> doi_bibtex("10.48550/arXiv.1706.03762") |> println
@misc{https://doi.org/10.48550/arxiv.1706.03762,
  doi = {10.48550/ARXIV.1706.03762},
  url = {https://arxiv.org/abs/1706.03762},
  author = {Vaswani, Ashish and Shazeer, Noam and Parmar, Niki and Uszkoreit, Jakob and Jones, Llion and Gomez, Aidan N. and Kaiser, Lukasz and Polosukhin, Illia},
  keywords = {Computation and Language (cs.CL), Machine Learning (cs.LG), FOS: Computer and information sciences, FOS: Computer and information sciences},
  title = {Attention Is All You Need},
  publisher = {arXiv},
  year = {2017},
  copyright = {arXiv.org perpetual, non-exclusive license}
}
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

## Preferences

Some parts of this package are configured using Preferences.jl. The easiest way to set
preferences is using PreferenceTools.jl as follows:
```
julia> using PreferenceTools

julia> # press ] to enter the Pkg REPL

pkg> preference add DOIs csl_style=bibtex csl_locale=en-GB
```

Allowed preferences:
- `url`: The URL prefix of any DOI requests (default: `"https://dx.doi.org"`)
- `csl_style`: The CSL style of citations from `doi_citation`.
- `csl_locale`: The CSL locale of citations from `doi_citation`.
