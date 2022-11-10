---
title: 'Operator dashboard for controlling the NeIC Sensitive Data Archive'
title_short: 'Operator dashboard for the NeIC Sensitive Data Archive'
tags:
  - onboarding
  - Federated EGA
  - sensitive data
authors:
  - name: Stefan Negru
    orcid: 0000-0002-6544-5022
    affiliation: 1
  - name: Next person
    orcid: XXX
    affiliation: 2
affiliations:
  - name: CSC – IT CENTER FOR SCIENCE, Finland
    index: 1
date: 11 Nov 2022
cito-bibliography: paper.bib
event: BioHackEU22
biohackathon_name: "BioHackathon-Europe"
biohackathon_url:   "https://biohackathon-europe.org/"
biohackathon_location: "Paris, France, 2022"
group: Project 20
# URL to project git repo --- should contain the actual paper.md:
git_url: https://github.com/neicnordic/sda-dashboard
# This is the short authors description that is used at the
# bottom of the generated paper (typically the first two authors):
authors_short: People \emph{et al.}
---


<!--

The paper.md, bibtex and figure file can be found in this repo:

  https://github.com/journal-of-research-objects/Example-BioHackrXiv-Paper

To modify, please clone the repo. You can generate PDF of the paper by
pasting above link (or yours) in

  http://biohackrxiv.genenetwork.org/

-->

# Introduction

The European Genome-phenome Archive (EGA) is a service for permanent archiving and sharing personally identifiable genetic and phenotypic data resulting from biomedical research projects. The Federated EGA, consisting of the Central and Federated EGA nodes, will be a distributed network of repositories for sharing human -omics data and phenotypes. Each node of the federation is responsible for its own infrastructure and the connection to the Central EGA. Currently, the adoption and deployment of a new federated node is challenging due to the complexity of the project and the diversity of technological solutions used, in order to ensure the secure archiving of the data and the transfer of the information between the nodes.

The goal of this project is to develop a suite consisting of simple scripts that would help newcomers to the federation to deeply understand the main concepts, while enabling them to get involved in the development of the technology as quickly as possible.

In order to achieve that, we are planning to focus on the main pipeline, handling the archiving of the data submitted by users. Specifically, the goal is to create a number of scripts that would lead the user/developer through the process followed from submitting a file to archiving it and making it available for downloading. The scripts will shed light on the processes under the hood, including the messaging between the services, the records stored in the database as well as the tools used for encrypting and decrypting the data. By the end of the biohackathon, we aim to have a suite that will ease the onboarding of new members of the Federation.


# Results

## FEGA Onboarding



The following tasks were accomplished as part of the BioHackathon:

\begin{enumerate}
\item Represent datasets and their related metadata
\item Represent family and pedigree information to support clinical knowledge
\item Make the provenance model more rich and descriptive
\end{enumerate}

(note the list is written in embedded LaTeX)

# Discussion


## Acknowledgements

We thank the organisers of the BioHackathon-Europe 2022 for travel support for some of the authors.


## Tables and figures

Tables can be added in the following way, though alternatives are possible:

| Header 1 | Header 2 |
| -------- | -------- |
| item 1 | item 2 |
| item 3 | item 4 |

Table: Note that table caption is automatically numbered.


| Term                | MB tools/ontologies using this term | Frequency on Biology Stack Exchange | Search Term         |
|:-------------------:|:-----------------------------------:|:-----------------------------------:|:-------------------:|
| Part | iGEM | 9065 | part + parts |
| Component           | SBOL, SBOLDesigner, SBOLCanvas      | 2163                                | component           |
| Module              | SBOL                                | 311                                 | module              |
| Device              |                                     | 677                                 | device              |
| System              |                                     | 16098                               | system              |
| RBS                 |                                     | 548                                 | rbs                 |
| Ribosome Entry Site | SO                                  | 8                                   | ribosome entry site |

LaTeX table:



\begin{tabular}{|l|l|}\hline
Age & Frequency \\ \hline
18--25  & 15 \\
26--35  & 33 \\
36--45  & 22 \\ \hline
\end{tabular}

## Mermaid graphs

This is an example of embedding a graph

```mermaid
graph TD;
    A-->B;
    A-->C;
    B-->D;
    C-->D;
```

Unfortunately it does not work without the mermaid plugin and that requires headless chrome(?!). If you run the command line version of `gen-pdf` it may be possible to get it to work with the right packages. Please tell us if you succeed.

## References
