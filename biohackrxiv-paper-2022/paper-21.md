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
  - name: Dimitris Bampalikis
    affiliation: 1
    orcid: 
  - name: Silvia Bahena
    affiliation: 2
    orcid: 
  - name: Marcos Casado Barbero
    affiliation: 2
    orcid: 
  - name: Betül Eren Keskin
    affiliation: 3
    orcid: 
  - name: Shreyas Shivakumara
    affiliation: 3
    orcid: 
  - name: Joshua Baskaran
    affiliation: 4
    orcid: 
affiliations:
  - name: Uppsala University, ICM, blabla
    index: 1
  - name: CRG???
    index: 2
  - name: Linköping
    index: 3
  - name: Norway
    index: 4
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

Human genome and phenom data is classified as special categories under the EU
GDPR legislation and this requires special care to be taken when re-using this
data. To enable this in a compliant way the Federated EGA was established in
2022[TODO citation]. The Federated EGA is built on top of the already existing
European Genome/Phenome Arcive (EGA). The nordic countries, Norway, Finland and
Sweden together with Spain and Germany represent the first federated partners.

In the nordics we have collaborated around a codebase for the federated EGA, we
have done this under the umbrella of the Nordic e-Infrastructure Collaboration
(NeIC)[TODO citation] where we've had three projects over the last 7 years,
Tryggve[CITE], Tryggve2[CITE] and now Heilsa[CITE].

As we in the nordics now move into production there is a need for both System
Administrators and Helpdesk staff to be able to control and inspect the system.
We need to answer questions related to operations, identify errors in order to
better manage the services and infrastructure. To standardize the workflow with
the operator dashboard we aim to build an MVP for such an “Operator Dashboard”.

# Results

## Grafana dashboard

We used grafana[TODO: cite] to create a Minimal Viable Product (MVP) of a
dashboard to view the state and interact with system.

There are two main views into the system. The first one is an overview over all
files and what state they are in, whether they have been moved from the inbox,
if they've been backed up and if they have gotten the EGAF identifiers from
Central EGA[TODO: cite], see Figure 1. It is possible from this view to also
click on a file to go to the second view with information about all events that
has happened to that specific file, to aid the helpdesk staff in the task of
supporting the submitting researcher, see Figure 2.

We also made a proof-of-concept of controlling the system through the
dashboard. It's possible to click on a "Retry" link and then the state of a
file changes from whatever it is already in to "Uploaded" instead, we didn't
have enough time to also restart the ingestion pipeline.

# Future Work


## Acknowledgements

We thank the organisers of the BioHackathon-Europe 2022 for travel support for
some of the authors.

## References
