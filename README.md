# Network Analysis

This is a home for network-related demos and examples.

Contents
============

- [Applications](applications/)
    -  [Fraud](applications/fraud)
        - [Fraud Rings in Bank Data](applications/fraud/fraud-rings-in-bank-data)
    -  [Natural Language Processing](applications/natural-language-processing)
        - [Word Embeddings for Approximate Pattern Matching](applications/natural-language-processing/word-embeddings-for-approximate-pattern-matching)
    -  [Social](applications/social)
        - [Inmate Network](applications/social/inmate-network)

Getting Started
============

System requirements
-------------------
- [SAS Viya](https://www.sas.com/en_us/software/viya.html)
   - Visual Data Mining and Machine Learning license required for network algorithm execution
- [graphviz](https://www.graphviz.org/)
   - for network visualizations
- python and required packages
   - for jupyter notebook execution
   - packages used in this demo are given in [requirements.txt](requirements.txt)

Running instructions
--------------------
- To clone with submodule dependency, use `git clone --recursive <REPO_URL>`
   - or if you cloned without `--recursive`, run `git submodule update --init`
- Modify [common/conf/environment.txt](common/conf/environment.txt) with your CAS server information
   - provided by your SAS Viya system admistrator
- Launch a SAS Studio window to run SAS scripts (*.sas)
- Or, launch a jupyter notebook to run notebooks (*.ipynb)