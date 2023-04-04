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
  - name: Johan Viklund
    orcid: 0000-0003-1984-8522
    affiliation: 5
  - name: Albert Hornos Vidal
    orcid: 0000-0002-7330-668X
    affiliation: 4
  - name: Liisa Lado-Villar
    orcid:
    affiliation: 1
  - name: Alexandros Dimopoulos
    orcid: 0000-0002-4602-2040
    affiliation: 2
  - name: David Salgado
    orcid: 0000-0002-5905-3591
    affiliation: 3
  - name: Konstantinos Koumpouras
    orcid:
    affiliation: 5
  - name: Martin Norling
    orcid:
    affiliation: 5
  - name: Dimitris Bampalikis
    affiliation: 5
    orcid: 0000-0002-2078-3079
  - name: Silvia Bahena
    affiliation: 6
    orcid: 0000-0002-2734-0449
  - name: Marcos Casado Barbero
    affiliation: 6
    orcid: 
affiliations:
  - name: CSC – IT CENTER FOR SCIENCE, Espoo, Finland
    index: 1
  - name: Hellenic Naval Academy, Piraeus, Greece
    index: 2
  - name: Institut national de la santé et de la recherche médicale (Inserm), Paris, France
    index: 3
  - name: Instituto Nacional de Bioinformática (INB), Barcelona, Spain
    index: 4
  - name: National Bioinformatics Infrastructure Sweden (NBIS), Uppsala University, SciLifeLab, ICM - Department of Cell and Molecular Biology, Uppsala, Sweden.
    index: 5
  - name: European Molecular Biology Laboratory - European Bioinformatics Institute (EMBL-EBI), Hinxton CB10 1SD, UK.
    index: 6
date: 11 Nov 2022
cito-bibliography: paper.bib
event: BioHackEU22
biohackathon_name: "BioHackathon-Europe"
biohackathon_url:  "https://biohackathon-europe.org/"
biohackathon_location: "Paris, France, 2022"
group: "Project 20"
# URL to project git repo --- should contain the actual paper.md:
git_url: "https://github.com/neicnordic/sda-dashboard/tree/feature/biohackrxiv-papers/biohackrxiv-paper-2022/paper-20"
# This is the short authors description that is used at the
# bottom of the generated paper (typically the first two authors):
authors_short: Negru S \emph{et al.}
---

# Introduction

The European Genome-phenome Archive (EGA) [@EGA] (also known as Central EGA - cEGA) is a service for permanent archiving and sharing personally identifiable genetic and phenotypic data resulting from biomedical research projects. The Federated EGA [@FEGA], consisting of the Central and Federated EGA nodes, will be a distributed network of repositories for sharing human -omics data and phenotypes. Each node of the federation is responsible for its own infrastructure and the connection to the Central EGA. Currently, the adoption and deployment of a new federated node is challenging due to the complexity of the project and the diversity of technological solutions used, in order to ensure the secure archiving of the data and the transfer of the information between the nodes.

The goal of this project was to develop an onboarding suite consisting of simple scripts, supplemented by documentation, that would help newcomers to the EGA federation in order understand in depth the main concepts, while enabling them to get involved in the development of the technology as quickly as possible.

At the same time we aimed to identify existing technologies and standards
across FEGA nodes that can be used as a reference to upcoming nodes.

This biohackathon project is a result of a nordic collaboration under the umbrella of the Nordic e-Infrastructure Collaboration(NeIC)[https://neic.no/] [@NEIC] where we've had three projects over the last 7 years, [Tryggve1](https://neic.no/tryggve1/)
[@Tryggve1], [Tryggve2](https://neic.no/tryggve2/) [@Tryggve2] and now [Heilsa](https://neic.no/heilsa) [@Heilsa]. For this reason the source code and scripts are shared in the same repository as the "Operator dashboard for controlling the NeIC Sensitive Data Archive" (Project 21) from BioHackathon-Europe 2022.

# Results

In order to achieve the project goals, our plan is to focus on the main pipeline, handling the archiving of the data submitted by users to Federated EGA. Specifically, the goal is to create a number of scripts that would lead the user/developer through the process followed from submitting a file to archiving it and making it available for downloading. 

The scripts aimed to provide some clarity on the processes under the hood, including the messaging between (sent via [RabbitMQ](https://www.rabbitmq.com/)) the services, the records stored in the database as well as the tools used for encrypting and decrypting the data.

The following tasks were accomplished as part of the BioHackathon:

\begin{enumerate}
\item Identify the roles that could be part of operation of an Federated EGA node, at the same time specify the needs for each role;
\item Identify the technical requirements joining the federation;
\item Develop a software stack containing the main services for testing purposes and document connections between the services;
\end{enumerate}

## Roles Involved in a Federated EGA Node

In order to focus our work during the biohackathon we decided to first identify the roles involved in running a Federated EGA node:

* **Node Representative** - aims to understand what services need to be adjusted for their node so that they can run the federated EGA in their infrastructure;
* **Developer** - needs documentation about the starting points of the code base, in order to start reading, as well as a demo stack of the services;
* **Operator** - requires a technical checklist to see if the node is technically ready to join federated EGA
* **Helpdesk** - wants to see the files a submitter has submitted, in order to be able to assist in the submission process
* **Submitter** - would need to submit data to a Federated EGA node.

Our attention was towards *Developers* and *Submitters* with the starter pack, while the documentation we produced aimed to help *Node Representative* and *Operator* roles.

Given that the *Submitter* role covers a broader spectrum of questions that such a role might have we decided to focus on the encryption of files, which is a requirement for a file to be correctly submitted.
We underestood that an easy tool that can assist me to encrypt the files (using Crypt4GH [@crypt4gh]) so we aimed to identify and document how such a tool could be utilized.

## FEGA Technical Requirements

We summarized the technical requirements for joining the federation in the following table:

|  # |           Component           |                                                                                                                          Description                                                                                                                          |   Link to  |
|:--:|:-----------------------------:|:-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------:|:----------:|
| 1  | URL                           | Official website for documentation                                                                                                                                                                                                                            |            |
| 2  | Credentials                   | For connecting to Central EGA there are 2 types of credentials required:  User API for identifying and validating in Submitter Inbox the cEGA accounts cEGA MQ credentials for connecting FEGA Node MQ                                                        |            |
| 3  | FEGA Node Encryption key pair | A Crypt4GH key pair generated by the FEGA  Node, and the public is shared with the Submitter so that files are sent  encrypted for the FEGA Node                                                                                                              |            |
| 4  | FEGA Node MQ                  | RabbitMQ which is connected in shovel and federation mechanism with the cEGA MQ                                                                                                                                                                               | 2          |
| 5  | Submitter Inbox               | An Inbox solution for the Researcher to submit files to a specific Node (e.g. SFTP, REST API). The Inbox needs to be accessible by a Researcher via an URL.                                                                                                   | 2, 3       |
| 6  | Ingest Pipeline               | Means of interfacing with the cEGA so that the  required messages are being sent at relevant steps of the submission  process. https://localega.readthedocs.io/en/latest/amqp.html                                                                            | 4, 7, 8, 9 |
| 7  | Archive storage               | Storage solution for storing archived files.  e.g. S3, POSIX etc.                                                                                                                                                                                             | 6          |
| 8  | Archive File Database         | Means of storing information about the  archived files and their AccessionIDs and dataset IDs mapping to  AccessionIDs (file to dataset mapping). Note: other details can be stored in the database e.g. checksums, timestamps, headers of crypt4gh file etc. | 6          |
| 9  | Backup Storage                | Storage solution for storing a backup of the archived files.  e.g. S3, POSIX etc. Note: A file needs to be backed up in a different location than the Archive                                                                                                 | 6          |
| 10 | Main Source Code Repository   | Where the source code can be found                                                                                                                                                                                                                            |            |
| 11 | Main Programming Language     | Main programming language for the technical stack pipeline                                                                                                                                                                                                    |            |
| 12 | Deployment Method             | Means which technology is used to put in production different components                                                                                                                                                                                      |            |
| 13 | Helpdesk Management System    | Main tool for user/helpdesk communication                                                                                                                                                                                                                     |            |
| 14 | Helpdesk Portal Technology    | Federated EGA node helpedesk will provide  means of interacting with submitter, registering DPA, establisng DACs  and monitoring submissions.                                                                                                                 | 15         |
| 15 | Monitoring Tool               | Means of providing an overview of the status of submissions. Good also for auditing purposes.                                                                                                                                                                 | 14         |
| 16 | Metadata Submission Method    | Means how the researchers will send the metadata to Central EGA through a cEGA submitter portal, node portal or another solution                                                                                                                              |            |
| 17 | Download Solution             | Means for a Requester to access the data once approval has been granted.                                                                                                                                                                                      | 7, 8, 18   |
| 18 | Data Access Tool              | Means of enabling Requesters to Download the archived data. tool for facilitating DACs                                                                                                                                                                        |            |
| 19 | General Contact               | Email or website to contact the team deploying the solution                                                                                                                                                                                                   |            |

Table: Federated EGA Technical Requirements

From the table above the require points are: 2,3,4,5,6,7,8,9,16,17,19.

This information is augumented with technologies utilized by current nodes (as of November 2022): in a fork of the [FEGA-Onboarding documentation](https://ahornos.github.io/FEGA-onboarding/topics/technical-operational/#technical-requirements).

### Encryption

All sensitive data uploaded to a FEGA node need to be encrypted using the Crypt4GH standard. For encrypting, apart from the file itself, all one needs are the following 2 types of keys:

1. The public key used for the encryption which is provided by the FEGA node. One of the available Crypt4GH implementations:

- [Crypt4GH python](https://github.com/EGA-archive/crypt4gh) module or [crypt4gh-gui python](https://github.com/CSCfi/crypt4gh-gui) module wrapper with GUI;
- [crypth4gh go](https://github.com/neicnordic/crypt4gh) implementation or [sdi-cli](https://github.com/NBISweden/sda-cli) go wrapper;
- [crypt4gh-rust](https://github.com/EGA-archive/crypt4gh-rust) Rust implementation;
- [Crypt4GH Java](https://github.com/uio-bmi/crypt4gh) implementation;
- [htslib-crypt4gh](https://github.com/samtools/htslib-crypt4gh) C implementation;
- [Crypt4GH C](https://github.com/silverdaz/crypt4gh) implementation.

2. Optionally a private key created locally by the user 


## Federated EGA Starter Stack

The FEGA Started Stack from: https://github.com/neicnordic/sda-dashboard was developed against the services developed in the Heilsa project, however another similar stack was identified at: [LocalEGA](https://github.com/EGA-archive/LocalEGA) .

During the Elixir Biohackathon 2022 the starter stack was developed further, bugs fixed and tested by members of two nodes (Greece and France) that were new to the Federated EGA workflow.

The bootstrapping script was able to illustrate the communication that happens between cEGA and FEGA node detailing the messages that are being sent between the two RabbitMQ, for example:

- Ingest Message

Message received from Central EGA to start ingestion at a Federated EGA node.

Processed by the the sda-pipeline `ingest` service.

```
{
   "type": "ingest",
   "user":"john.smith@smth.org",
   "filepath":"somedir/encrypted.file.c4gh",
   "encrypted_checksums": [
      { "type": "md5",
      "value": 
      "1a79a4d60de6718e8e5b326e338ae533"},
      { "type": "sha256", 
      "value": 
      "50d858e0985ecc7f60418aaf0cc5ab587f42c2570a884095a9e8ccacd0f6545c"}
   ]
}
```

- Accession ID Message

Each file will receive an accession ID from Central EGA and this is done via a message sent from Central EGA to a Federated EGA node.

Processed by the the sda-pipeline `finalize` service.
```
{
    "type": "accession",
    "user": "john.smith@smth.org",
    "filepath": "somedir/encrypted.file.c4gh",
    "accession_id": "EGAF00000123456",
    "decrypted_checksums": [ 
        { "type": "sha256", 
        "value": 
        "50d858e0985ecc7f60418aaf0cc5ab587f42c2570a884095a9e8ccacd0f6545c" },
        { "type": "md5",
        "value": "1a79a4d60de6718e8e5b326e338ae533" }
    ]
}
```

# Conclusions and Future work

Part of the members that joined our project represented two nodes that were considering joining the federation, and with their help we were able to identify the missing gaps in the technical requirements, documentation and starter stack, and ultimately were able to guide them through the process of submitting files using the starter stack.

By taking into account different roles we were able to identify existing gaps in our how we documented the services developed within the Heilsa project and it was also quite useful for the development team working with the code-base and deployments as they could more easily get feedback from new nodes, that had little knowledge on how the messages and operations of FEGA can be organized.

The outputs of the Technical requirements have been presented to the Federated EGA Operations Committee and the aim is to reflect the in future versions of the [FEGA-Onboarding](https://ega-archive.github.io/FEGA-onboarding/) documentation.

One of the clear directions is that, given the number services required to run a FEGA node, we aim to simplify our setup and streamline our code base.

# Acknowledgements

We thank the organisers of the BioHackathon-Europe 2022 for travel support for some of the authors.

# References
