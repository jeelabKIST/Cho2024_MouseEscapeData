# Cho2024_MouseEscapeData

🔗 Mouse Escape Behaviors and mPFC-BLA Activity Dataset: Understanding Flexible Defensive Strategies Under Threat (DOI: [10.1038/s41597-024-03688-0](https://doi.org/10.1038/s41597-024-03688-0))

💡 Please email Jee Hyun Choi at jeechoi@kist.re.kr or SungJun Cho at sungjun.cho@ndcn.ox.ac.uk with any questions or concerns. Alternatively, you can simply raise a GitHub issue.

---

## 🔥 Getting Started

This repository hosts the scripts required to replicate the burst detection analysis and the figures presented in the Technical Validation section of our paper.

For installation, download the repository folder, modify the paths to reflect the folder's location, and execute the scripts. Please note that, to ensure the scripts run properly, it is necessary to install EEGLAB (v2023.0) and download our dataset. The EEGLAB software is available for download from its official [website](https://sccn.ucsd.edu/eeglab/download.php), while our dataset is accessible through the GIN G-Node [repository](https://gin.g-node.org/JEELAB/Mouse-threat-and-escape-CBRAIN) (within `data_BIDS` directory).

After downloading, move EEGLAB to the `utils` folder and `data_BIDS` to the main directory for easier access. For instance, you can run:

```
git clone https://github.com/jeelabKIST/Cho2024_MouseEscapeData.git
cd Cho2024_MouseEscapeData/
mv ../eeglab2023.0 ./utils
mv ../data_BIDS ./
```

## 📝 Guidelines

### Main Scripts

* **NOTE:** Please execute the main scripts in the sequence outlined below. To ensure that the `analyze_*.m` scripts run successfully, save the burst detections by running `detect_bursts.m` first.

    | File                            | Description                                                                          |
    | :------------------------------ | :----------------------------------------------------------------------------------- |
    | `detection_outlines.m`          | Plots exemplary burst events and summarizes the burst detection method.               |
    | `detect_bursts.m`               | Detects neural bursts from the mouse LFP recordings.                                  |
    | `analyze_beta_vs_gamma.m`       | Compares the beta and high gamma burst occurrence rates under the solitary condition. |
    | `analyze_solitary_vs_group.m`   | Compares the burst occurrence rates between the solitary and group conditions.        |

### Utility

* `utils` include MATLAB functions necessary for running the main scripts. Every function script includes a description about its inputs and outputs. Please refer to each script for further details.

## 🎯 Requirements
The analyses and visualizations in this paper had following dependencies:

```
MATLAB 2022b
EEGLAB v2023.0
```

## 🪪 License
Copyright (c) 2024-Present [SungJun Cho](https://github.com/scho97) and [Jee Lab](https://www.jeelab.net/). `Cho2024_MouseEscapeData` is a free and open-source software licensed under the [MIT License](https://github.com/jeelabKIST/Cho2024_MouseEscapeData/blob/main/LICENSE).
