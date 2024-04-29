% This script conducts all preprocessing steps, including artefact
% rejection (muscle and SQUID jump), and ICA components removal. ICA per se
% was performed in another script, for computational efficiency.

% Using sub001 as the example.

%% Load the workspace
addpath('/home/common/matlab/fieldtrip');
ft_defaults;
load('/project/3027010.01/middata/sub1_downsampled.mat');
%% Artefact detection: jump
cfgj = [];
cfgj.trl = trl_new;
%cfgj.datafile = datafile;
%cfgj.headerfile = hdrfile;
cfgj.continuous = 'yes';
% jump artefact
cfgj.artfctdef.jump.channel = 'M*O*'; % first check jump noise in occipital channels
cfgj.artfctdef.jump.cutoff  = 45; 
cfgj.artfctdef.jump.trlpadding = 0;
cfgj.artfctdef.jump.artpadding = 0;
cfgj.artfctdef.jump.fltpadding = 0;
% algorithmic params
cfgj.artfctdef.jump.cumulative = 'yes';
cfgj.artfctdef.jump.medianfilter  = 'yes';
cfgj.artfctdef.jump.medianfiltord = 9;
cfgj.artfctdef.jump.absdiff       = 'yes';
% interactive
cfgj.artfctdef.jump.interactive = 'yes';

[cfgj, artifact_jump] = ft_artifact_jump(cfgj, datadwn);
%% Artefact detection: muscle
cfgmus = [];
cfgmus.trl = trl_new;
%cfgmus.datafile = datafile;
%cfgmus.headerfile = hdrfile;
cfgmus.continuous = 'yes';

cfgmus.artfctdef.zvalue.channel      = 'MEG'; 
cfgmus.artfctdef.zvalue.cutoff       = 28;
cfgmus.artfctdef.zvalue.trlpadding   = 0;
cfgmus.artfctdef.zvalue.fltpadding   = 0;
cfgmus.artfctdef.zvalue.artpadding   = 0.1;
%algorithmic params
cfgmus.artfctdef.zvalue.bpfilter     = 'yes';
cfgmus.artfctdef.zvalue.bpfreq       = [110 140]; % muscle noise often represented as high-freq
cfgmus.artfctdef.zvalue.bpfiltord    = 9; % band-pass filter order
cfgmus.artfctdef.zvalue.bpfilttype   = 'but'; % butterworth filter
cfgmus.artfctdef.zvalue.hilbert      = 'yes';
cfgmus.artfctdef.zvalue.boxcar       = 0.2;
%interactive
cfgmus.artfctdef.zvalue.interactive = 'yes';

[cfgmus, artifact_muscle] = ft_artifact_zvalue(cfgmus,datadwn);

%% Artefact rejection (jump & muscle)
cfgrej=[];
cfgrej.artfctdef.reject = 'complete'; % this rejects complete trials, use 'partial' if you want to do partial artifact rejection
cfgrej.artfctdef.jump.artifact = artifact_jump;
cfgrej.artfctdef.muscle.artifact = artifact_muscle;
%cfgrej.artfctdef.ecg.artifact = artifact_ecg;

datarej = ft_rejectartifact(cfgrej, datadwn);

%% Detection/check: jump (second time, all MEG channels)
% if there isn't any significant jumps, skip the rejection

cfgj = [];
cfgj.trl = datarej.sampleinfo;
%cfgj.datafile = datafile;
%cfgj.headerfile = hdrfile;
cfgj.continuous = 'yes';
% jump artefact 
cfgj.artfctdef.jump.channel = 'MEG';
cfgj.artfctdef.jump.cutoff  = 40; 
cfgj.artfctdef.jump.trlpadding = 0;
cfgj.artfctdef.jump.artpadding = 0;
cfgj.artfctdef.jump.fltpadding = 0;
% algorithmic params
cfgj.artfctdef.jump.cumulative = 'yes';
cfgj.artfctdef.jump.medianfilter  = 'yes';
cfgj.artfctdef.jump.medianfiltord = 9;
cfgj.artfctdef.jump.absdiff       = 'yes';
% interactive
cfgj.artfctdef.jump.interactive = 'yes';

[cfgj, artifact_jump2] = ft_artifact_jump(cfgj, datarej);

%% Artefact detection: muscle
cfgmus = [];
cfgmus.trl = datarej.sampleinfo;
%cfgmus.datafile = datafile;
%cfgmus.headerfile = hdrfile;
cfgmus.continuous = 'yes';

cfgmus.artfctdef.zvalue.channel      = 'MEG'; 
cfgmus.artfctdef.zvalue.cutoff       = 28; 
cfgmus.artfctdef.zvalue.trlpadding   = 0;
cfgmus.artfctdef.zvalue.fltpadding   = 0;
cfgmus.artfctdef.zvalue.artpadding   = 0.1; 
%algorithmic params
cfgmus.artfctdef.zvalue.bpfilter     = 'yes';
cfgmus.artfctdef.zvalue.bpfreq       = [110 140]; % muscle noise often represented as high-freq
cfgmus.artfctdef.zvalue.bpfiltord    = 9; % band-pass filter order
cfgmus.artfctdef.zvalue.bpfilttype   = 'but'; % butterworth filter
cfgmus.artfctdef.zvalue.hilbert      = 'yes';
cfgmus.artfctdef.zvalue.boxcar       = 0.2;
%interactive
cfgmus.artfctdef.zvalue.interactive = 'yes';

[cfgmus, artifact_muscle2] = ft_artifact_zvalue(cfgmus,datarej);

%% Artefact rejection (second run, jump & muscle)
%artefact_second = artifact_jump2([16:33,48:50],:);

cfgrej=[];
cfgrej.artfctdef.reject = 'complete'; % this rejects complete trials, use 'partial' if you want to do partial artifact rejection
%cfgrej.artfctdef.jump.artifact = artefact_second;
cfgrej.artfctdef.muscle.artifact = artifact_muscle2;
%cfgrej.artfctdef.ecg.artifact = artifact_ecg;

datarej = ft_rejectartifact(cfgrej, datarej);


%% save datafile
save('/project/3027010.01/middata/sub1_rej.mat','datarej','-v7.3');

%% load datafile
addpath('/home/common/matlab/fieldtrip');
ft_defaults;
load('/project/3027010.01/middata/sub1_ica.mat');
load('/project/3027010.01/middata/sub1_rej.mat');
%% ICA: ocular movements & others
%% run ICA
cfgica        = [];
cfgica.method = 'runica'; % this is the default and uses the implementation from EEGLAB
cfgica.channel = 'MEG';
%cfgica.runica.pca = 339;
comp = ft_componentanalysis(cfgica, datarej);

%% plot the components for visual inspection (with interested components specified)
figure
cfgpica = [];
cfgpica.component = 1:20;       % specify the component(s) that should be plotted
cfgpica.layout    = 'CTF151.lay'; % specify the layout file that should be used for plotting
cfgpica.comment   = 'no';
ft_topoplotIC(cfgpica, comp);
% save the plot for later checks

%% further inspection on the time course of all components
cfgtcica = [];
%cfgtcica.component  = [1 21 53];
cfgtcica.layout = 'CTF151.lay'; 
cfgtcica.viewmode = 'component';
ft_databrowser(cfgtcica, comp);

%% remove the bad components and backproject the data
cfgremica = [];
cfgremica.component = [1 45 14 23 110 35 38 41 46 47 61 62 64 83 91 115 135 19 73 144 22]; % to be removed component(s)
dataica = ft_rejectcomponent(cfgremica, comp, datarej);

%% save results
save('/project/3027010.01/middata/sub1_final.mat','dataica','-v7.3');