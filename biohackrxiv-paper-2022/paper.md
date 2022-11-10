---
title: 'Operator dashboard for controlling the NeIC Sensitive Data Archive'
title_short: 'Operator dashboard for the NeIC Sensitive Data Archive'
tags:
  - dashboard
  - grafana
  - sensitive data
authors:
  - name: Johan Viklund
    orcid: 0000-0003-1984-8522
    affiliation: 1
  - name: Next person
    orcid: XXX
    affiliation: 2
affiliations:
  - name: Uppsala University, ICM, blabla
    index: 1
  - name: Database Center for Life Science, Research Organization of Information and Systems, Japan
    index: 2
date: 11 Nov 2022
cito-bibliography: paper.bib
event: BioHackEU22
biohackathon_name: "BioHackathon-Europe"
biohackathon_url:   "https://biohackathon-europe.org/"
biohackathon_location: "Paris, France, 2022"
group: Project 21
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

The countries Finland, Sweden, Norway, Denmark and Estonia are collaborating in
the NeIC Heilsa project to develop software and operate federated EGA nodes. We
want to bring developers from all partnering countries together to work on an
operator dashboard for our software stack.

As we move into a mature operational ecosystem there is a need for both System
Administrators and Helpdesk staff to be able to control and inspect the system.
We need to answer questions related to operations, identify errors in order to
better manage the services and infrastructure. To standardize the workflow with
the operator dashboard we aim to build an MVP for such an “Operator Dashboard”.
There will be a view on the sensitive data archive that will provide Helpdesk
with means to identify issues such as number of submissions per user, failed
submission and the reason, or how many times a dataset has been accessed,
accession identifiers for datasets and their associated files etc. For system
admins the main objective is to have means to trace errors and investigate
failed submissions or to spot issues related to downloading/accessing
datasets/files. We also want to have the ability to modify and retry failed
jobs and make safe manual updates to specific database fields.

We have not implemented any dashboard or control interfaces before and we hope
that by bringing this project to the hackathon we can get input from people in
different organizations on best practices for design and what we might not have
thought about for the dashboard.


# Results

## Grafana dashboard



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
