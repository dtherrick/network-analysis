# Network Analysis

This is a home for network-related demos and examples.

## Table of Contents

- [Applications](applications/)
    -  [Fraud](applications/fraud)
        - [Fraud Rings in Bank Data](applications/fraud/fraud-rings-in-bank-data)
    -  [Natural Language Processing](applications/natural-language-processing)
        - [Word Embeddings for Approximate Pattern Matching](applications/natural-language-processing/word-embeddings-for-approximate-pattern-matching)
    -  [Social](applications/social)
        - [Inmate Network](applications/social/inmate-network)

## Overview

This repository contains examples and demonstrations of the network analysis capabilities available in SAS® Viya.

### Prerequisites

- [SAS Viya](https://www.sas.com/en_us/software/viya.html)
   - Visual Data Mining and Machine Learning license required for network algorithm execution
- [graphviz](https://www.graphviz.org/)
   - for network visualizations
- python>=3.6.5 and required packages
   - for jupyter notebook execution
   - packages used in this demo are given in [pyproject.toml](pyproject.toml) and [poetry.lock](poetry.lock)
   - We recommend using [Poetry](https://python-poetry.org) for virtual environment and package management. See the next section for instructions to install Poetry.
   -  

### Installation

**Quick Start**
- To clone with submodule dependency, use `git clone --recursive <REPO_URL>`
   - or if you cloned without `--recursive`, run `git submodule update --init`
- Modify [common/conf/environment.txt](common/conf/environment.txt) with your CAS server information
   - provided by your SAS Viya system admistrator
- Launch a SAS Studio window to run SAS scripts (*.sas)
- Or, launch a jupyter notebook to run notebooks (*.ipynb)

**Details**
- Clone the repository as specified under **Quick Start** above.
- If Poetry is not installed, install as follows from the terminal:
  - OSX / Linux / Bash On Windows: `curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python -`
  - Windows Powershell: `(Invoke-WebRequest -Uri https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py -UseBasicParsing).Content | python -`
- Create your virtual environment and install the project's Python dependencies with the following command (executed in the root directory of the repository (where the `pyproject.toml` and `poetry.lock` are located)).
  - `poetry install`
- After the virtual environment is created, and dependencies are installed, activate the virtual environment with the following command:
  - `poetry shell`
- Make the following modifications within [common/conf/environment.txt](common/conf/environment.txt) to enable connections to a Cloud Analytic Services (CAS) server. Contact your SAS system administrator (or person who deployed SAS® Viya) for more information:
   - CAS_SERVER_HOST=<i>set this to the hostname of your CAS server</i>
   - CAS_SERVER_PORT=<i>set this to the port of your CAS server</i>
 - Alternatively, some of the notebooks show how to connect to a CAS server when the host and port are set as shell environment variables. Create those variables:
   - `export CAS_SERVER_HOST='<set thie to the hostname of your CAS server>'`
   - `export CAS_SERVER_PORT='<set thie to the port of your CAS server>'`

### Running

- If you intend to run the SAS language script versions of these demos:
   - Open SAS Studio in a web browser. Contact your SAS system administrator for the URL to access SAS Studio.
   - Navigate to the directory where you cloned this repository, and then navigate to the sas/ directory of the demo you wish to run.
   - Open the .sas script and run by clicking the run icon or pressing F3.
- If you intend to run the Jupyter notebook versions of these demos:
   - First ensure that you are have the required python packages installed by using `poetry install` from a terminal window (see the above details section for more context).
   - Start your jupyter server. This repository installs both **jupyterlab** and the traditional notebook.
     - if you prefer the traditional notebook, invoke `jupyter notebook`
     - if you prefer the lab, invoke `jupyter lab`
   - On launch, the server should automatically open a web browser in the local home directory where you cloned this repository.
   - open the .ipynb notebook and then run the cells interactively by clicking the run button.

### Viewing graphs with graphviz
The SAS language scripts in various examples and demos produce graph visualizations produced with graphviz, which are saved in files with the extension .dot. To View them, you can convert them to to a rendered format, such as .png, with the command `dot -Tpng sample.dot > sample.png`. If you do not have graphviz installed, there are also online graphviz viewers that may be used to convert your .dot file content to an image.

## Contributing

We welcome your contributions! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on how to submit contributions to this project. 

## License

This project is licensed under the [Apache 2.0 License](LICENSE).

## Additional Resources

For more information, please visit the following:

**Documentation**
* [Proc Network: API documentation, Examples, and Theory for PROC NETWORK](https://go.documentation.sas.com/?cdcId=pgmsascdc&cdcVersion=default&docsetId=casmlnetwork&docsetTarget=titlepage.htm&locale=en)
* [Proc OptNetwork: API documentation, Examples, and Theory for PROC OPTNETWORK](https://go.documentation.sas.com/?cdcId=pgmsascdc&cdcVersion=default&docsetId=casnopt&docsetTarget=titlepage.htm&locale=en)
* [CAS Action Sets API Documentation](https://go.documentation.sas.com/?cdcId=pgmsascdc&cdcVersion=default&docsetId=allprodsactions&docsetTarget=actionSetsByName.htm&locale=en)

**Blog Posts**
* [The art and science of finding answers in connected data](https://blogs.sas.com/content/subconsciousmusings/2020/11/30/the-art-and-science-of-working-with-in-connected-data/)
* [Mobility tracing: Helping local authorities in the fight against COVID-19](https://blogs.sas.com/content/sascom/2020/07/08/mobility-tracing-helping-local-authorities-in-the-fight-against-covid-19/)
* [Using data visualization to solve a global cybersecurity incident](https://blogs.sas.com/content/subconsciousmusings/2020/12/03/using-data-visualization-to-solve-a-global-cybersecurity-incident/)
* [Incorporating Network Optimization in Data Science: The Graph Coloring Problem](https://www.linkedin.com/pulse/incorporating-network-optimization-data-science-graph-jay-laramore/)

**SAS Global Forum**
* [SAS Global Forum paper on pattern matching: Theory and performance comparisons with other graph database vendors](https://www.sas.com/content/dam/SAS/support/en/sas-global-forum-proceedings/2019/3353-2019.pdf)
* [SAS Global Forum tutorial on using Network to improve Machine Learning Models](https://youtu.be/dStT9Au2bN0)
