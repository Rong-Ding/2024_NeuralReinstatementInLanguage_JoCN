The folder contains scripts for three different analysis stages: preprocessing, RSA, and statistical analysis.

The scripts for preprocessing are used on raw data. Preprocessing scripts applied to subject001 are provided as an example.

The scripts for RSA may be divided into four categories:
- data organisation: transforming preprocessed data into RSA correlations (including time-frequency analysis)
- TFresult chunking: a function embedded in the data organisation function, to chunk and organise data per time*time unit
- worddist: to calculate the word distance thershold for non-matching word pairs so that the median distance remains identical between matching and non-matching word pairs
- TF_RSA: to conduct RSA correlations per frequency band in a synthesised script

The scripts for statistical analysis performs permutation.

Adapted scripts for analyses shown in the appendices are also provided.
