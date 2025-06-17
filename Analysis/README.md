## Analysis
Several subfolders are present, each devoted to presenting scripts of particular use (e.g., MEG data preprocessing, RSA, permutation stats). Importantly, to see a demo of RSA and stats analysis, you can check out the following scripts:

<b>TF_phase_RSA_allfreq.m (in the folder RSA):</b>\
This script implements **RSA** over time-frequency responses of preprocessed MEG data. In this script, self-written functions such as _data_organisation_phase_TFR_2.m_ and _TFresult_chunking_phase.m_ (both available under the same folder) are called to select, chunk, and reorganise neural data to make them usable for subsequent RSA.

<b>permutation_fieldtrip_main.m (in the folder Statistics_permutation):</b>\
This script implements **permutation statistics** on the saved data from the RSA between neural activity of pronouns and referent words. In the script, we fit the data into a statistical toolbox _Fieldtrip_ to draw statistically driven conclusions, and then visualise the results.

<b>Add_POS.ipynb (in the folder Appendix):</b>\
This script uses Python packages such as _pandas_ and _numpy_ to **align and integrate heterogeneous word annotation datasets** from various sources (in this case, story files) into one dataset. The goal is to visualise the part-of-speech (POS) information for each word position (-7~+7) surrounding target words. Then, the proportion of each POS category per word position is plotted in a stacked bar graph.
