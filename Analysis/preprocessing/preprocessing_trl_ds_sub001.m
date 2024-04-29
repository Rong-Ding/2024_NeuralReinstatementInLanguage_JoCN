% As part of preprocessing, this script defines trials (pronouns and referents) 
% and downsamples trial data per participant
% Using sub001 as an example

%% set Fieldtrip to path
addpath('/home/common/matlab/fieldtrip');
ft_defaults;

%% Define trials
baseloc = '/project/3027007.01/raw/';
sub = 'sub-001';
subj_base = [baseloc sub '/ses-meg01/meg/'];
folder = dir(subj_base);
filename = [subj_base folder(3).name];

cfg = [];
cfg.dataset = filename;
cd /home/lacnsg/rondin/Project1/scripts;
cfg.trialfun                = 'trialfunpronoun';
cfg                         = ft_definetrial(cfg);

%% Preprocessing
trl = cfg.trl;
datafile = cfg.datafile;
hdrfile = cfg.headerfile;

cfg.continuous              = 'yes';
[data] = ft_preprocessing(cfg);

%% Browsing the data
%cfgview = []; 
%cfgview.viewmode = 'vertical'; 
%cfgview = ft_databrowser(cfg, datadwn);
%% Downsampling
cfgdwn = [];
%cfgdwn.datafile = datafile;
%cfgdwn.headerfile = hdrfile;
cfgdwn.resamplefs = 400;
datadwn = ft_resampledata(cfgdwn, data);

trl_new = trl;
trl_new(:,1) = round(trl(:,1)/3 + 1/3);
trl_new(:,2) = round(trl(:,2)/3 + 1/3);
trl_new(:,3) = round(trl(:,3)/3 + 1/3);
%% Save the workspace
save('/project/3027010.01/middata/sub1_downsampled.mat','datadwn','trl_new','-v7.3');
