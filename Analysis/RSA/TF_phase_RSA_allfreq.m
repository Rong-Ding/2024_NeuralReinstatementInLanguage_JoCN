function [flag] = TF_phase_RSA_allfreq(subnum)
% This function generates correlations values between each two pronoun and
% referent trials per frequency band. 
% For each band, data_organisation func computes cell_RSA, which is a 50*50 cell, 
% with each unit containing averaged values of matching (1) and non-matching (0)
% trial pairs. 
% The function computes and produces cell_RSA in parallel for each subject.

% Process: First compute the TF for 1-30Hz, then run the RSAs

% To submit the func to DCCN HPC:
% addpath /home/common/matlab/fieldtrip/qsub/;
% out = qsubcellfun(@TF_phase_RSA_full_lower, {1,3,4,5,8,9,10,11,13,14,15,17,18,19,20,21,23,24,25,26,27,28,29,30,32,33}, 'memreq', 6.4e10, 'timreq', 7*60*60, 'stack', 'auto');

sub = ['sub' num2str(subnum)];

%% load data
file = ['/project/3027010.01/middata/' sub '_final.mat'];
data = load(file);
dataica = data.dataica;
addpath('/home/common/matlab/fieldtrip');
ft_defaults;

%% TF analyses: 1-30Hz
cfgtf1              = [];
cfgtf1.output       = 'fourier';
cfgtf1.channel      = 'MEG';
cfgtf1.method       = 'wavelet';
%cfgtf1.taper        = 'hanning';
cfgtf1.keeptrials   = 'yes';
cfgtf1.foi          = 1:1:30;
cfgtf1.width        = 3 + (cfgtf1.foi-1).*7./(length(cfgtf1.foi)-1);  % 3-10 cycles per time window
cfgtf1.toi          = -0.5:0.05:2.0;
TFR30 = ft_freqanalysis(cfgtf1, dataica);
%% transfer the results into phase
fourierspctrm = angle(TFR30.fourierspctrm);
TFR30.fourierspctrm = fourierspctrm;

%% main analyses RSA
%% delta
TFR = TFR30;
freqwin = [1 3];

channels = "T";
step = 0.05;
time1 = 0.05/step + 1;
time2 = 0.05/step + 1;
bas = [-0.3 -0.1];
split_band = 'no split';
subj = sub;

cd '/home/lacnsg/rondin/Project1/scripts';
[cell_RSA] = data_organisation_phase_TFR_2(TFR,freqwin,channels,time1,time2,bas,split_band,subj);

datafile = ['/project/3027010.01/middata/Corr/1208_all/full/phase/delta/' sub '_RSA_phase.mat'];
save(datafile,'cell_RSA','-v7.3'); % datafile names have been changed by mistake!!!!

%% theta
freqwin = [4 7];

cd '/home/lacnsg/rondin/Project1/scripts';
[cell_RSA] = data_organisation_phase_TFR_2(TFR,freqwin,channels,time1,time2,bas,split_band,subj);

datafile = ['/project/3027010.01/middata/Corr/1208_all/full/phase/theta/' sub '_RSA_phase.mat'];
save(datafile,'cell_RSA','-v7.3');

%% alpha
freqwin = [8 12];

cd '/home/lacnsg/rondin/Project1/scripts';
[cell_RSA] = data_organisation_phase_TFR_2(TFR,freqwin,channels,time1,time2,bas,split_band,subj);

datafile = ['/project/3027010.01/middata/Corr/1208_all/full/phase/alpha/' sub '_RSA_phase.mat'];
save(datafile,'cell_RSA','-v7.3');

%% beta
freqwin = [13 20];

cd '/home/lacnsg/rondin/Project1/scripts';
[cell_RSA] = data_organisation_phase_TFR_2(TFR,freqwin,channels,time1,time2,bas,split_band,subj);

datafile = ['/project/3027010.01/middata/Corr/1208_all/full/phase/beta/' sub '_RSA_phase.mat'];
save(datafile,'cell_RSA','-v7.3');

%% control analyses
%% delta
freqwin = [1 3];

channels = "T";
step = 0.05;
time1 = 0.05/step + 1;
time2 = 0.05/step + 1;
bas = [-0.3 -0.1];
split_band = 'no split';
subj = sub;

cd '/home/lacnsg/rondin/Project1/scripts';
[cell_RSA_ref,cell_RSA_pro] = data_org_words_phase_TFR(TFR,freqwin,channels,time1,time2,bas,split_band,subj);

datafile = ['/project/3027010.01/middata/Corr/1208_all/control/phase/delta/' sub '_RSA_words_phase.mat'];
save(datafile,'cell_RSA_ref','cell_RSA_pro','-v7.3');

%% theta
freqwin = [4 7];

cd '/home/lacnsg/rondin/Project1/scripts';
[cell_RSA_ref,cell_RSA_pro] = data_org_words_phase_TFR(TFR,freqwin,channels,time1,time2,bas,split_band,subj);

datafile = ['/project/3027010.01/middata/Corr/1208_all/control/phase/theta/' sub '_RSA_words_phase.mat'];
save(datafile,'cell_RSA_ref','cell_RSA_pro','-v7.3');

%% alpha
freqwin = [8 12];

cd '/home/lacnsg/rondin/Project1/scripts';
[cell_RSA_ref,cell_RSA_pro] = data_org_words_phase_TFR(TFR,freqwin,channels,time1,time2,bas,split_band,subj);

datafile = ['/project/3027010.01/middata/Corr/1208_all/control/phase/alpha/' sub '_RSA_words_phase.mat'];
save(datafile,'cell_RSA_ref','cell_RSA_pro','-v7.3');

%% beta
freqwin = [13 20];

cd '/home/lacnsg/rondin/Project1/scripts';
[cell_RSA_ref,cell_RSA_pro] = data_org_words_phase_TFR(TFR,freqwin,channels,time1,time2,bas,split_band,subj);

datafile = ['/project/3027010.01/middata/Corr/1208_all/control/phase/beta/' sub '_RSA_words_phase.mat'];
save(datafile,'cell_RSA_ref','cell_RSA_pro','-v7.3');

%% gamma
%% TF analyses: 35-80Hz
cfgtf2              = [];
cfgtf2.output       = 'fourier';
cfgtf2.channel      = 'MEG';
cfgtf2.method       = 'mtmconvol';
cfgtf2.taper        = 'dpss';
cfgtf2.keeptrials   = 'yes';
cfgtf2.foi          = 35:5:80;
cfgtf2.t_ftimwin    = 10./cfgtf2.foi;  % 10 cycles per time window
cfgtf2.toi          = -0.5:0.05:2.0;
cfgtf2.tapsmofrq       = 0.3.*cfgtf2.foi;
TFR150 = ft_freqanalysis(cfgtf2, dataica);

%% transfer the results into phase
fourierspctrm = angle(TFR150.fourierspctrm);
TFR150.fourierspctrm = fourierspctrm;

%% main analyses
freqwin = [35 80];

TFR = TFR150;
cd '/home/lacnsg/rondin/Project1/scripts';
[cell_RSA] = data_organisation_nobas_TFR_v2(TFR,freqwin,channels,time1,time2,bas,split_band,subj);

datafile = ['/project/3027010.01/middata/Corr/1208_all/full/phase/lowgamma/' sub '_RSA_phase.mat'];
save(datafile,'cell_RSA','-v7.3');

%% control analyses
cd '/home/lacnsg/rondin/Project1/scripts';
[cell_RSA_ref,cell_RSA_pro] = data_org_words_nobas_TFR(TFR,freqwin,channels,time1,time2,bas,split_band,subj);

datafile = ['/project/3027010.01/middata/Corr/1208_all/control/phase/lowgamma/' sub '_RSA_words_phase.mat'];
save(datafile,'cell_RSA_ref','cell_RSA_pro','-v7.3');

%%
flag = 'done';

end