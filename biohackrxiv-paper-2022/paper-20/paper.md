---
title: 'Onboarding suite for Federated EGA nodes'
title_short: 'Onboarding suite for Federated EGA nodes'
tags:
  - onboarding
  - Federated EGA
  - sensitive data
authors:
  - name: Stefan Negru
    orcid: 0000-0002-6544-5022
    affiliation: 1
  - name: Albert Hornos Vidal
    orcid: 0000-0002-7330-668X
    affiliation: 4
  - name: Alexandros Dimopoulos
    orcid: 0000-0002-4602-2040
    affiliation: 2
  - name: David Salgado
    orcid: 0000-0002-5905-3591
    affiliation: 3
  - name: Liisa Lado-Villar
    orcid:
    affiliation: 1
affiliations:
  - name: CSC – IT CENTER FOR SCIENCE, Finland
    index: 1
  - name: Hellenic Naval Academy, Greece
    index: 2
  - name: Institut national de la santé et de la recherche médicale, France
    index: 3
  - name: Instituto Nacional de Bioinformática (INB), Spain
    index: 4
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

The European Genome-phenome Archive (EGA)[@EGA] is a service for permanent archiving and sharing personally identifiable genetic and phenotypic data resulting from biomedical research projects. The Federated EGA[@FEGA], consisting of the Central and Federated EGA nodes, will be a distributed network of repositories for sharing human -omics data and phenotypes. Each node of the federation is responsible for its own infrastructure and the connection to the Central EGA. Currently, the adoption and deployment of a new federated node is challenging due to the complexity of the project and the diversity of technological solutions used, in order to ensure the secure archiving of the data and the transfer of the information between the nodes.

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

|  # |           Component           |                                                                                                                          Description                                                                                                                          | Required |   Link to  |
|:--:|:-----------------------------:|:-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------:|:--------:|:----------:|
| 1  | URL                           | Official website for documentation                                                                                                                                                                                                                            | -        |            |
| 2  | Credentials                   | For connecting to Central EGA there are 2 types of credentials required:  User API for identifying and validating in Submitter Inbox the cEGA accounts cEGA MQ credentials for connecting FEGA Node MQ                                                        | Y        |            |
| 3  | FEGA Node Encryption key pair | A Crypt4GH key pair generated by the FEGA  Node, and the public is shared with the Submitter so that files are sent  encrypted for the FEGA Node                                                                                                              | Y        |            |
| 4  | FEGA Node MQ                  | RabbitMQ which is connected in shovel and federation mechanism with the cEGA MQ                                                                                                                                                                               | Y        | 2          |
| 5  | Submitter Inbox               | An Inbox solution for the Researcher to submit files to a specific Node (e.g. SFTP, REST API). The Inbox needs to be accessible by a Researcher via an URL.                                                                                                   | Y        | 2, 3       |
| 6  | Ingest Pipeline               | Means of interfacing with the cEGA so that the  required messages are being sent at relevant steps of the submission  process. https://localega.readthedocs.io/en/latest/amqp.html                                                                            | Y        | 4, 7, 8, 9 |
| 7  | Archive storage               | Storage solution for storing archived files.  e.g. S3, POSIX etc.                                                                                                                                                                                             | Y        | 6          |
| 8  | Archive File Database         | Means of storing information about the  archived files and their AccessionIDs and dataset IDs mapping to  AccessionIDs (file to dataset mapping). Note: other details can be stored in the database e.g. checksums, timestamps, headers of crypt4gh file etc. | Y        | 6          |
| 9  | Backup Storage                | Storage solution for storing a backup of the archived files.  e.g. S3, POSIX etc. Note: A file needs to be backed up in a different location than the Archive                                                                                                 | Y        | 6          |
| 10 | Main Source Code Repository   | Where the source code can be found                                                                                                                                                                                                                            | N        |            |
| 11 | Main Programming Language     | Main programming language for the technical stack pipeline                                                                                                                                                                                                    | -        |            |
| 12 | Deployment Method             | Means which technology is used to put in production different components                                                                                                                                                                                      | -        |            |
| 13 | Helpdesk Management System    | Main tool for user/helpdesk communication                                                                                                                                                                                                                     | N        |            |
| 14 | Helpdesk Portal Technology    | Federated EGA node helpedesk will provide  means of interacting with submitter, registering DPA, establisng DACs  and monitoring submissions.                                                                                                                 | N        | 15         |
| 15 | Monitoring Tool               | Means of providing an overview of the status of submissions. Good also for auditing purposes.                                                                                                                                                                 | N        | 14         |
| 16 | Metadata Submission Method    | Means how the researchers will send the metadata to Central EGA through a cEGA submitter portal, node portal or another solution                                                                                                                              | Y        |            |
| 17 | Download Solution             | Means for a Requester to access the data once approval has been granted.                                                                                                                                                                                      | Y        | 7, 8, 18   |
| 18 | Data Access Tool              | Means of enabling Requesters to Download the archived data. tool for facilitating DACs                                                                                                                                                                        | N        |            |
| 19 | General Contact               | Email or website to contact the team deploying the solution                                                                                                                                                                                                   | Y        |            |

Table: Federated EGA Technical Requirements


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
