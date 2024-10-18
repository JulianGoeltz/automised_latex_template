# Template to automatically build ![LaTeX](https://upload.wikimedia.org/wikipedia/commons/thumb/9/92/LaTeX_logo.svg/60px-LaTeX_logo.svg.png) documents with GitHub
Make use of docker-powered GitHub workflows to automatically create figures (`python` and `TikZ`) and compile a `pdf` in a standardised fashion, independent of local settings.


## Repository state
### [![see latest pdf](https://img.shields.io/static/v1?label=PDF&logo=adobeacrobatreader&message=see%20latest%20version&color=success)](../../blob/compiledPDF/main.pdf)
[![compile pdf](../../workflows/compile%20pdf/badge.svg)](../../actions/workflows/latex_compile.yml)
[![Linter](../../workflows/Linter/badge.svg)](../../actions/workflows/linter.yml)

## Why this repo
The idea is comparable to [overleaf.com](https://www.overleaf.com), but with two significant changes: making full use of git features as well as create plots during the build process.
Regarding git, [overleaf states](https://www.overleaf.com/blog/195-new-collaborate-online-and-offline-with-overleaf-and-git-beta)
> It's also worth noting that you can use whatever git branching model you like locally, but you can only push changes to the master branch on Overleaf. 

I, personally, make a lot of use of multiple branches, especially in combination with the GitHub pull requests and when working together with other people. This was the initial reason for me to find a solution for `LaTeX` group projects. 
[The texlive docker container of DANTE EV](https://github.com/dante-ev/docker-texlive) combines well with the GitHub Actions to automatically build the `main.tex` at each commit.

Additionally, [the gridspeccer](https://github.com/gridspeccer/gridspeccer) project is used as a helper script to automate the plotting of multi-panel figures.
`gridspeccer` has a lot of flexibilities while enabling adaptions in a quick and straightforward manner; however, it is no requirement if you don't need plots, [or use alternative plotting methods](additionalInfo.md#gridspeccer-alternative).

This template is most useful for scientific papers, and was used, e.g., for
* Göltz, J.∗, Kriener, L.∗, Baumbach, A., Billaudelle, S., Breitwieser, O., Cramer, B., ... & Petrovici, M. A. (2021). Fast and energy-efficient neuromorphic deep learning with first-spike times. [*Nature Machine Intelligence*, 3(9), 823-835.](https://www.nature.com/articles/s42256-021-00388-x), 3(9), 823-835. preprint at https://arxiv.org/abs/1912.11443
* Haider, P., Ellenberger, B., Kriener, L., Jordan, J., Senn, W., & Petrovici, M. A. (2021). Latent equilibrium: A unified learning theory for arbitrarily fast computation with arbitrarily slow neurons. [*Advances in Neural Information Processing Systems*](https://papers.nips.cc/paper/2021/hash/94cdbdb84e8e1de8a725fa2ed61498a4-Abstract.html), 34, 17839-17851. preprint at https://arxiv.org/abs/2110.14549
* Ellenberger, B.∗, Haider, P.∗, Jordan, J., Max, K., Jaras, I., Kriener, L., ... & Petrovici, M. A. (2024). Backpropagation through space, time, and the brain. preprint at https://arxiv.org/abs/2403.16933.
* Göltz, J.∗, Weber, J.∗, Kriener, L.∗, Lake, P., Payvand, M., & Petrovici, M. A. (2024). DelGrad: Exact gradients in spiking networks for learning transmission delays and weights. preprint at https://arxiv.org/abs/2404.19165.
* Kriener, L.∗, Völk, K.∗, von Hünerbein, B., Benitez, F., Senn, W., & Petrovici, M. A. (2024). ELiSe: Efficient Learning of Sequences in Structured Recurrent Networks. preprint at https://arxiv.org/abs/2402.16763.

## Build instruction
### On GitHub
When adhering to [the repo structure](additionalInfo.md#repository-structure), the [workflows](additionalInfo.md#github-actions) will build the document automatically.

> [!IMPORTANT]  
> At the end of the GitHub Action that compiles the `pdf`, this `pdf` is pushed to the repository in a special branch, which requires **Read and write permissions**. This permission is set in `Settings->Actions>General` under `Workflow permissions` in your repository, unfortunately the default setting only includes read permissions therefore the compile action will fail until you change this.

### On your local machine
For details see [the detailed build information](additionalInfo.md#local-build-instruction), but as a quick guide:
after installing the requirements with `pip install -r requirements.txt` (ideally in a [`venv`](https://docs.python.org/3/library/venv.html)), `make fig_python && make` builds the manuscript.

The repository is structured to have the `python` plot scripts in `/code` and the plots are created in `/fig`.
In case the figures need to be additionally adapted with `TikZ`, those scripts are located in `/fig_tikz`.
The main `.tex` file is located in the root folder `/main.tex`.

## Todos
* Online build time is currently 4 minutes, with the majority used to set up the container. Potentially one wants to speed up this process; or make the builds more sparse, i.e., check every 15 minutes if something happened, if so build, otherwise don't. see https://stackoverflow.com/questions/63014786/how-to-schedule-a-github-actions-nightly-build-but-run-it-only-when-there-where ; or stop older builds https://stackoverflow.com/questions/58895283/stop-already-running-workflow-job-in-github-actions
