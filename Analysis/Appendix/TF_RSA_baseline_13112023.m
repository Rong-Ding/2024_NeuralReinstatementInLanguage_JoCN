function [flag] = TF_RSA_baseline_13112023(subnum)
% First compute the TF for 1-30Hz, then run the RSAs
%addpath /home/common/matlab/fieldtrip/qsub/;
%out = qsubcellfun(@TF_RSA_bas_13112023, {1,3,4,5,8,9,10,11,13,14,15,17,18,19,20,21,23,24,25,26,27,28,29,30,32,33}, 'memreq', 6.4e10, 'timreq', 7*60*60, 'stack', 'auto');
sub = ['sub' num2str(subnum)];

%% load data
file = ['/project/3027010.01/middata/' sub '_final.mat'];
data = load(file);
dataica = data.dataica;
addpath('/home/common/matlab/fieldtrip');
ft_defaults;

%% TF analyses: 1-30Hz
cfgtf1              = [];
cfgtf1.output       = 'pow';
cfgtf1.channel      = 'MEG';
cfgtf1.method       = 'wavelet';
%cfgtf1.taper        = 'hanning';
cfgtf1.keeptrials   = 'yes';
cfgtf1.foi          = 1:1:30;
cfgtf1.width        = 2 + (cfgtf1.foi-1).*8./(length(cfgtf1.foi)-1);  % 2-10 cycles per time window
cfgtf1.toi          = -1:0.05:2; % as cycles change into 2, toi extends
TFR30 = ft_freqanalysis(cfgtf1, dataica);

%% main analyses
%% delta
TFR = TFR30;
freqwin = [1 3];
channels = "T";
step = 0.05;
time1 = 0.05/step + 1;
time2 = 0.05/step + 1;
bas = [-1 -0.8]; % the other baseline time window: [-0.3 -0.1]
split_band = 'no split';
subj = sub;

cd '/home/lacnsg/rondin/Project1/scripts';
[cell_RSA] = data_organisation_bas_TFR_rev_bas_subset_19112023(TFR,freqwin,channels,time1,time2,bas,split_band,subj);

datafile = ['/project/3027010.01/middata/Corr/20231113_basRSA/subset_far_bas/power/delta/' sub '_RSA_nobas.mat'];
save(datafile,'cell_RSA','-v7.3');

%% theta
freqwin = [4 7];

cd '/home/lacnsg/rondin/Project1/scripts';
[cell_RSA] = data_organisation_bas_TFR_rev_bas_subset_19112023(TFR,freqwin,channels,time1,time2,bas,split_band,subj);

datafile = ['/project/3027010.01/middata/Corr/20231113_basRSA/subset_far_bas/power/theta/' sub '_RSA_nobas.mat'];
save(datafile,'cell_RSA','-v7.3');

%% alpha
freqwin = [8 12];

cd '/home/lacnsg/rondin/Project1/scripts';
[cell_RSA] = data_organisation_bas_TFR_rev_bas_subset_19112023(TFR,freqwin,channels,time1,time2,bas,split_band,subj);

datafile = ['/project/3027010.01/middata/Corr/20231113_basRSA/subset_far_bas/power/alpha/' sub '_RSA_nobas.mat'];
save(datafile,'cell_RSA','-v7.3');

%% beta
freqwin = [13 20];

cd '/home/lacnsg/rondin/Project1/scripts';
[cell_RSA] = data_organisation_bas_TFR_rev_bas_subset_19112023(TFR,freqwin,channels,time1,time2,bas,split_band,subj);

datafile = ['/project/3027010.01/middata/Corr/20231113_basRSA/subset_far_bas/power/beta/' sub '_RSA_nobas.mat'];
save(datafile,'cell_RSA','-v7.3');

%%
flag = 'done';

end