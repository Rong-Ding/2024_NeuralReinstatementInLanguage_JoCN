## 💭 Reinstatement of neural activity underlying referents in pronoun understanding
This is a MATLAB-based project aiming to study how the referent of a pronoun is represented in the neural sense. 

As an example, in a sentence _Mike is walking to Lily. He wears blue._, when you see/hear _He_, _Mike_ comes to your mind. 
We hypothesised that oscillatory neural activity underlying processing of the referent (e.g., _Mike_) is **reinstated**, or (re)activated, when your brain is retrieving from memory what a pronoun (e.g., _He_) refers to. 

To test the hypothesis, we conducted a state-of-the-art, multivariate neural decoding technique, namely **representational similarity analysis (RSA)**, to analyse the similarity between neurophysiological activity (recorded with MEG) underlying referent words and pronouns.

The current repository is forked from a repository first published by our lab GitHub that contained all the scripts and relevant materials. In this repository, you can find stimulus annotations and pipelines used for data analysis. You can find the results of the current project in a published, peer-reviewed paper: 
Rong Ding, Sanne ten Oever, Andrea E. Martin; Delta-band Activity Underlies Referential Meaning Representation during Pronoun Resolution. J Cogn Neurosci 2024; doi: https://doi.org/10.1162/jocn_a_02163

## Content
- Folder **Analysis**: scripts to perform preprocessing, RSA, and permutation statistics.
- Folder **Stimulus annotations**: part-of-speech annotations used to perform the POS analysis (as an appendix).
- File "wordinfo_nounRef_new_v2.csv": annotations of word stimuli (i.e., pronouns and referents), their referents, timing, etc..

### Analysis:
Several subfolders are present, each devoted to presenting scripts of particular use (e.g., MEG data preprocessing, RSA, permutation stats). Importantly, to see a demo of RSA and stats analysis, you can check out the following scripts:

<b>TF_phase_RSA_allfreq.m (in the folder RSA):</b>\
This script implements RSA over time-frequency responses of preprocessed MEG data. In this script, self-written functions such as _data_organisation_phase_TFR_2.m_ and _TFresult_chunking_phase.m_ (both available under the same folder) are called to select, chunk, and reorganise neural data to make them usable for subsequent RSA.

<b>permutation_fieldtrip_main.m (in the folder Statistics_permutation):</b>\
This script implements permutation statistics on the saved data from the RSA between neural activity of pronouns and referent words. In the script, we fit the data into a statistical toolbox _Fieldtrip_ to draw statistically driven conclusions, and then visualise the results.

<b>Add_POS.ipynb (in the folder Appendix):</b>\
This script uses Python packages such as _pandas_ and _numpy_ to align and integrate heterogeneous word annotation datasets from various sources (in this case, story files) into one dataset. The goal is to visualise the part-of-speech (POS) information for each word position (-7~+7) surrounding target words. Then, the proportion of each POS category per word position is plotted in a stacked bar graph.


### Stimulus annotations:
In this folder, there are word annotations per story as well as POS annotations used to perform the POS analysis as an appendix.

The file "wordinfo_nounRef_new_v2.csv" contains annotations of word stimuli (i.e., pronouns and referents), their referents, timing, etc..

You can find the results of the current project in a published, peer-reviewed paper: 
Rong Ding, Sanne ten Oever, Andrea E. Martin; Delta-band Activity Underlies Referential Meaning Representation during Pronoun Resolution. J Cogn Neurosci 2024; doi: https://doi.org/10.1162/jocn_a_02163
