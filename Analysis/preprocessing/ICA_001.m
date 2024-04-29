% This script performs ICA. 
% ICA was separated from the rest of preprocessing steps originally for
% computational efficiency.

% Using sub001 as an example.

%% load datafile
addpath('/home/common/matlab/fieldtrip');
ft_defaults;
load('/project/3027010.01/middata/sub1_rej.mat');
%% run ICA
cfgica        = [];
cfgica.method = 'runica'; % this is the default and uses the implementation from EEGLAB
cfgica.channel = 'MEG';
%cfgica.runica.pca = 339;
comp = ft_componentanalysis(cfgica, datarej);

%% save datafile
save('/project/3027010.01/middata/sub1_ica.mat','comp','-v7.3');