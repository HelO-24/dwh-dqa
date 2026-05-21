# dwh-dqa
# DWH Data Quality & Assurance Repository

## Overview
This repository contains all code and documentation relating to the DWH Data Quality & Assurance (DQA) capability.
It provides a central, version‑controlled location for all data quality and assurance logic, ensuring that rules and metrics are:

Consistent

Auditable

Reusable across systems

Versioned and reviewed through GitHub workflows

## Repository Structure
The repository is organised into logical folders representing different categories of DQA logic.

Scripts/
Documentation/
deployment/

Each folder may include its own README describing structure, naming conventions, and usage.

## Branching Model
This repository follows the Basic Collaboration Model.

### main
Contains production‑ready SQL for DQA metrics.
This branch is protected and updated only after successful deployment.

### development
Integration branch for the next release.
All approved work is merged here before deployment.

### feature branches
Developers create feature branches for each change.
Naming convention:
feature/<work-item>-<short-description>

Example:
feature/DQ-70-add-data-retention-procedure

Feature names should include the Jira reference where applicable.

## Workflow

Create a feature branch from development.

Implement or update DQA SQL logic.

Commit and push your branch.

Raise a pull request into development.

Reviewer validates logic, performance, and impact.

Merge into development.

After deployment, merge development into main and tag the release.

## Pull Request Requirements
All pull requests must include:

Clear description of the rule or logic added

List of affected tables, views, or metrics

Test results (before/after values, sample outputs)

Rollback plan

Reference to related work items

## Data Quality Standards
This repository follows the organisation’s Data Quality Framework, including:

Naming conventions for rules and metrics

Consistent structure for profiling queries

Performance‑aware SQL patterns

Clear documentation for each rule

## Deployment Process
Deployment scripts for DQA logic are stored in the deployment/ folder.

The deployment process includes:

Generating rule updates

Updating exception‑handling logic

Validating metrics post‑deployment

Tagging the release in main

## Governance and Compliance
This repository adheres to:

GitHub Governance Policy

Branch Protection Policy

Data Quality Framework Standards

## Getting Started
To begin working in this repository:

Clone the repository locally

Ensure you have access to the development SQL environment

Review the folder structure and documentation

Follow the branching model and workflow described above

\## Contact
For questions or support, contact the DWH Team or repository maintainers.
