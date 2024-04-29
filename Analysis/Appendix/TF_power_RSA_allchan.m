function [flag] = TF_power_RSA_allchan(subnum)
% First compute the TF for 1-30Hz, then run the RSAs
%addpath /home/common/matlab/fieldtrip/qsub/;

sub = ['sub' num2str(subnum)];
baseloc = '/project/3027010.01/middata/TF30/';
file = [baseloc sub '_TF30.mat'];
TFR30 = load(file);

%% main analyses
%% delta
TFR = TFR30.TFR30;
freqwin = [1 3];
channels = "all";
step = 0.05;
time1 = 0.05/step + 1;
time2 = 0.05/step + 1;
bas = [-0.3 -0.1];
split_band = 'no split';
subj = sub;

cd '/home/lacnsg/rondin/Project1/scripts';
[cell_RSA] = data_organisation_nobas_TFR_v2(TFR,freqwin,channels,time1,time2,bas,split_band,subj);

datafile = ['/project/3027010.01/middata/Corr/20220725_allchans/power/delta/' sub '_RSA_nobas.mat'];
save(datafile,'cell_RSA','-v7.3');

%% theta
freqwin = [4 7];

cd '/home/lacnsg/rondin/Project1/scripts';
[cell_RSA] = data_organisation_nobas_TFR_v2(TFR,freqwin,channels,time1,time2,bas,split_band,subj);

datafile = ['/project/3027010.01/middata/Corr/20220725_allchans/power/theta/' sub '_RSA_nobas.mat'];
save(datafile,'cell_RSA','-v7.3');

%% alpha
freqwin = [8 12];

cd '/home/lacnsg/rondin/Project1/scripts';
[cell_RSA] = data_organisation_nobas_TFR_v2(TFR,freqwin,channels,time1,time2,bas,split_band,subj);

datafile = ['/project/3027010.01/middata/Corr/20220725_allchans/power/alpha/' sub '_RSA_nobas.mat'];
save(datafile,'cell_RSA','-v7.3');

%% beta
freqwin = [13 20];

cd '/home/lacnsg/rondin/Project1/scripts';
[cell_RSA] = data_organisation_nobas_TFR_v2(TFR,freqwin,channels,time1,time2,bas,split_band,subj);

datafile = ['/project/3027010.01/middata/Corr/20220725_allchans/power/beta/' sub '_RSA_nobas.mat'];
save(datafile,'cell_RSA','-v7.3');

%% control analyses
%% delta
freqwin = [1 3];
channels = "all";
step = 0.05;
time1 = 0.05/step + 1;
time2 = 0.05/step + 1;
bas = [-0.3 -0.1];
split_band = 'no split';
subj = sub;

cd '/home/lacnsg/rondin/Project1/scripts';
[cell_RSA_ref,cell_RSA_pro] = data_org_words_nobas_TFR(TFR,freqwin,channels,time1,time2,bas,split_band,subj);

datafile = ['/project/3027010.01/middata/Corr/20220725_allchans/control/power/delta/' sub '_RSA_words_nobas.mat'];
save(datafile,'cell_RSA_ref','cell_RSA_pro','-v7.3');

%% theta
freqwin = [4 7];

cd '/home/lacnsg/rondin/Project1/scripts';
[cell_RSA_ref,cell_RSA_pro] = data_org_words_nobas_TFR(TFR,freqwin,channels,time1,time2,bas,split_band,subj);

datafile = ['/project/3027010.01/middata/Corr/1208_all/control/power/nobas/theta/' sub '_RSA_words_nobas.mat'];
save(datafile,'cell_RSA_ref','cell_RSA_pro','-v7.3');

%% alpha
freqwin = [8 12];

cd '/home/lacnsg/rondin/Project1/scripts';
[cell_RSA_ref,cell_RSA_pro] = data_org_words_nobas_TFR(TFR,freqwin,channels,time1,time2,bas,split_band,subj);

datafile = ['/project/3027010.01/middata/Corr/20220725_allchans/control/power/alpha/' sub '_RSA_words_nobas.mat'];
save(datafile,'cell_RSA_ref','cell_RSA_pro','-v7.3');

%% beta
freqwin = [13 20];

cd '/home/lacnsg/rondin/Project1/scripts';
[cell_RSA_ref,cell_RSA_pro] = data_org_words_nobas_TFR(TFR,freqwin,channels,time1,time2,bas,split_band,subj);

datafile = ['/project/3027010.01/middata/Corr/20220725_allchans/control/power/beta/' sub '_RSA_words_nobas.mat'];
save(datafile,'cell_RSA_ref','cell_RSA_pro','-v7.3');

%%
flag = 'done';

end