## 💭 Reinstatement of neural activity underlying referents in pronoun understanding
This is a MATLAB-based project aiming to study how the referent of a pronoun is represented in the neural sense. 

As an example, in a sentence _Mike is walking to Lily. He wears blue._, when you see/hear _He_, _Mike_ comes to your mind. 
We hypothesised that oscillatory neural activity underlying processing of the referent (e.g., _Mike_) is **reinstated**, or (re)activated, when your brain is retrieving from memory what a pronoun (e.g., _He_) refers to. 

To test the hypothesis, we conducted a state-of-the-art, multivariate neural decoding technique, namely **representational similarity analysis (RSA)**, to analyse the similarity between neurophysiological activity (recorded with MEG) underlying referent words and pronouns.

The current repository is forked from a repository first published by our lab GitHub that contained all the scripts and relevant materials. In this repository, you can find stimulus annotations and pipelines used for data analysis. 

You can find the results of the current project in a published, peer-reviewed paper: 
Rong Ding, Sanne ten Oever, Andrea E. Martin; Delta-band Activity Underlies Referential Meaning Representation during Pronoun Resolution. J Cogn Neurosci 2024; doi: https://doi.org/10.1162/jocn_a_02163

## Content
- Folder **Analysis**: scripts to perform preprocessing, RSA, and permutation statistics.
- Folder **Stimulus annotations**: part-of-speech annotations used to perform the POS analysis (as an appendix).
- File "wordinfo_nounRef_new_v2.csv": annotations of word stimuli (i.e., pronouns and referents), their referents, timing, etc..
