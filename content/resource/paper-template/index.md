---
title: "Paper Template for Reproducible Empirical Papers (R Markdown)"
summary: "An open template that combines a linear R pipeline with an R Markdown manuscript, so that every number, table, and figure in a paper is produced by code."
date: "2026-10-29T00:00:00+01:00"
weight: 20

# Former URL (Resources section was first built on the project type).
aliases:
  - /project/paper-template/

external_link: ""
url_code: "https://github.com/mluenich/paper-template"
---

I have made the template I use for my empirical papers publicly available on GitHub: [**paper-template**](https://github.com/mluenich/paper-template). It combines a linear R pipeline with an R Markdown manuscript, so that every number, table, and figure in the paper is produced by code and can be rebuilt with a single command.

The pipeline is based on the way I write manuscripts with R and R Markdown and reflects many years of experience in writing research papers with an empirical focus. I used ChatGPT and Claude to refine the template and to prepare it for publication.

**How it is organized**

- **One entry point:** `source("R/00_run_all.R")` runs import, cleaning, analysis, and the preparation of tables and figures, and then renders the manuscript and an online appendix to PDF.
- **Central configuration:** paths, seeds, survey weights, and render options are set in one YAML file; machine-specific data paths can be kept in a local file that is not versioned.
- **Display-only manuscript:** the R Markdown files contain no analysis code. They load pre-built tables (APA style, with notes), figures, and pre-formatted values for in-text reporting.
- **Submission and open science support:** an optional anonymized version for peer review, an approximate word count, a session-info record, and a script that packs a reproduction package for OSF without raw data.

The repository also contains documentation of its architecture and working rules for LLM-assisted coding sessions.

To start a new project, use **Use this template** on GitHub or clone the repository; the README describes how to adapt it to a new study. The template is released under the MIT License, and I am happy to receive suggestions via GitHub issues.
