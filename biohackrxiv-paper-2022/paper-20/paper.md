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
affiliations:
  - name: CSC – IT CENTER FOR SCIENCE, Finland
	  index: 1
  - name: Hellenic Naval Academy, Greece
	  index: 2
  - name: Institut national de la santé et de la recherche médicale, France
	  index: 3
  - name: Instituto Nacional de Bioinformática (INB), Spain
	  index: 4
  - name: National Bioinformatics Infrastructure Sweden (NBIS), Sweden
	  index: 5
date: 11 Nov 2022
cito-bibliography: paper.bib
event: BioHackEU22
biohackathon_name: "BioHackathon-Europe"
biohackathon_url:   "https://biohackathon-europe.org/"
biohackathon_location: "Paris, France, 2022"
group: Project 20
# URL to project git repo --- should contain the actual paper.md:
git_url: https://github.com/neicnordic/sda-dashboard/tree/feature/biohackrxiv-papers/biohackrxiv-paper-2022/paper-20
# This is the short authors description that is used at the
# bottom of the generated paper (typically the first two authors):
authors_short: People \emph{et al.}
---

# Introduction

The European Genome-phenome Archive (EGA)[@EGA] is a service for permanent archiving and sharing personally identifiable genetic and phenotypic data resulting from biomedical research projects. The Federated EGA[@FEGA], consisting of the Central and Federated EGA nodes, will be a distributed network of repositories for sharing human -omics data and phenotypes. Each node of the federation is responsible for its own infrastructure and the connection to the Central EGA. Currently, the adoption and deployment of a new federated node is challenging due to the complexity of the project and the diversity of technological solutions used, in order to ensure the secure archiving of the data and the transfer of the information between the nodes.

The goal of this project was to develop an onboarding suite consisting of simple scripts, supplemented by documentation, that would help newcomers to the EGA federation in order understand in depth the main concepts, while enabling them to get involved in the development of the technology as quickly as possible.

At the same time we aimed to identify existing technologies and standards
across FEGA nodes that can be used as a reference to upcoming nodes.

This biohackathon project is a result of a nordic collaboration under the umbrella of the Nordic e-Infrastructure Collaboration (NeIC)[@NEIC] where we've had three projects over the last 7 years, [Tryggve1](https://neic.no/tryggve1/)[@Tryggve1], [Tryggve2](https://neic.no/tryggve2/)[@Tryggve2] and Heilsa[@Heilsa]. For this reason the source code and scripts are shared in the same repository as the `Operator dashboard for controlling the NeIC Sensitive Data Archive` (Project 21) from BioHackathon-Europe 2022.

# Results

In order to achieve the project goals, our plan to focus on the main pipeline, handling the archiving of the data submitted by users to Federated EGA. Specifically, the goal is to create a number of scripts that would lead the user/developer through the process followed from submitting a file to archiving it and making it available for downloading. The scripts will shed light on the processes under the hood, including the messaging between the services, the records stored in the database as well as the tools used for encrypting and decrypting the data.

The following tasks were accomplished as part of the BioHackathon:

\begin{enumerate}
\item Identify the roles that could be part of operation of an Federated EGA node, at the same time specify the needs for each role;
\item Identify the technical requirements joining the federation;
\item Develop a software stack containing the main services for testing purposes and document connections between the services;
\end{enumerate}

## Roles Involved in a Federated EGA Node

## FEGA Technical Requirements

|  # |       	Component       	|                                                                                                                      	Description                                                                                                                      	| Required |   Link to  |
|:--:|:-----------------------------:|:-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------:|:--------:|:----------:|
| 1  | URL                       	| Official website for documentation                                                                                                                                                                                                                        	| -    	|        	|
| 2  | Credentials               	| For connecting to Central EGA there are 2 types of credentials required:  User API for identifying and validating in Submitter Inbox the cEGA accounts cEGA MQ credentials for connecting FEGA Node MQ                                                    	| Y    	|        	|
| 3  | FEGA Node Encryption key pair | A Crypt4GH key pair generated by the FEGA  Node, and the public is shared with the Submitter so that files are sent  encrypted for the FEGA Node                                                                                                          	| Y    	|        	|
| 4  | FEGA Node MQ              	| RabbitMQ which is connected in shovel and federation mechanism with the cEGA MQ                                                                                                                                                                           	| Y    	| 2      	|
| 5  | Submitter Inbox           	| An Inbox solution for the Researcher to submit files to a specific Node (e.g. SFTP, REST API). The Inbox needs to be accessible by a Researcher via an URL.                                                                                               	| Y    	| 2, 3   	|
| 6  | Ingest Pipeline           	| Means of interfacing with the cEGA so that the  required messages are being sent at relevant steps of the submission  process. https://localega.readthedocs.io/en/latest/amqp.html                                                                        	| Y    	| 4, 7, 8, 9 |
| 7  | Archive storage           	| Storage solution for storing archived files.  e.g. S3, POSIX etc.                                                                                                                                                                                         	| Y    	| 6      	|
| 8  | Archive File Database     	| Means of storing information about the  archived files and their AccessionIDs and dataset IDs mapping to  AccessionIDs (file to dataset mapping). Note: other details can be stored in the database e.g. checksums, timestamps, headers of crypt4gh file etc. | Y    	| 6      	|
| 9  | Backup Storage            	| Storage solution for storing a backup of the archived files.  e.g. S3, POSIX etc. Note: A file needs to be backed up in a different location than the Archive                                                                                             	| Y    	| 6      	|
| 10 | Main Source Code Repository   | Where the source code can be found                                                                                                                                                                                                                        	| N    	|        	|
| 11 | Main Programming Language 	| Main programming language for the technical stack pipeline                                                                                                                                                                                                	| -    	|        	|
| 12 | Deployment Method         	| Means which technology is used to put in production different components                                                                                                                                                                                  	| -    	|        	|
| 13 | Helpdesk Management System	| Main tool for user/helpdesk communication                                                                                                                                                                                                                 	| N    	|        	|
| 14 | Helpdesk Portal Technology	| Federated EGA node helpe desk will provide  means of interacting with submitter, registering DPA, establishing DACs  and monitoring submissions.                                                                                                             	| N    	| 15     	|
| 15 | Monitoring Tool           	| Means of providing an overview of the status of submissions. Good also for auditing purposes.                                                                                                                                                             	| N    	| 14     	|
| 16 | Metadata Submission Method	| Means how the researchers will send the metadata to Central EGA through a cEGA submitter portal, node portal or another solution                                                                                                                          	| Y    	|        	|
| 17 | Download Solution         	| Means for a Requester to access the data once approval has been granted.                                                                                                                                                                                  	| Y    	| 7, 8, 18   |
| 18 | Data Access Tool          	| Means of enabling Requesters to Download the archived data. tool for facilitating DACs                                                                                                                                                                    	| N    	|        	|
| 19 | General Contact           	| Email or website to contact the team deploying the solution                                                                                                                                                                                               	| Y    	|        	|

Table: Federated EGA Technical Requirements

## Federated EGA Starter Stack


# Acknowledgements

We thank the organisers of the BioHackathon-Europe 2022 for travel support for some of the authors.

# References
