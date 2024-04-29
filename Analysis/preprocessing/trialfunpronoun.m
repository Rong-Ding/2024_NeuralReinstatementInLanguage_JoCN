function [trl,event] = trialfunpronoun(cfg)

%%
% Opening the MEG file and reading events into memory
baseloc = '/project/3027010.01/';

addpath('/home/common/matlab/fieldtrip');
ft_defaults;

hdr = ft_read_header(cfg.dataset);  % Fs
event = ft_read_event(cfg.dataset); % story onset triggers

%%
% read in the MEG audio file
cfg.channel = 'UADC003';
cfg.continuous = 'yes';
audch = ft_preprocessing(cfg);

% Determine the number of samples before and after the trigger
fs = hdr.Fs;
pre = -2  * fs;
post = 3.5  * fs;

% Identify story onset triggers and classify
stotype = [1 2 3 4 1 2 1 2 3;1 1 1 1 3 3 2 2 2]';
sel = find(strcmp({event.type}, 'UPPT001')); %find indices the story triggers
event = event(sel);

allwavs = dir([baseloc '*.wav']);
for cntwav = 1:length(allwavs)
   [wf1, fs_wav] = audioread([allwavs(cntwav).folder '/' allwavs(cntwav).name]);
   wf{cntwav} = resample(wf1, fs, fs_wav);
end

%%
% load timing of pronouns
TimingInfo = readtable([baseloc 'wordinfo_nounRef_new.csv']);

trl = [];
% build trials: referent & pronoun
for cntword = 1:height(TimingInfo)
   story = TimingInfo.story(cntword); % number of story
   story_part = TimingInfo.part(cntword); % part number
   TIS = TimingInfo.start(cntword); % start time
   wordcode = TimingInfo.code(cntword); % identity coded as number
   wordOrder = TimingInfo.wordOrder(cntword);
   condition = TimingInfo.condition(cntword); % ref/pro
   if string(condition) == 'referent' % dummy-code the ref & pronoun
    condition = 2;
   else
    condition = 1;
   end
   first_occ = TimingInfo.first_occur(cntword);
   if first_occ == 1 % recode the first occurrence; pronouns' will also be "0"
       first_occ = 1;
   else
       first_occ = 0;
   end
   
   
   % read the trigger of the story&part, to epoch meg data
   trig = 100 + story_part*10 + story;
   index = find([event.value] == trig);
   if isempty(index)
       continue
   end
   sample = event(index).sample + TIS*fs;
   
   eppre = 0.5;
   epw = 0.5;
   % epoch the wav file:
   wavcnt = find(stotype(:,1) == story_part & stotype(:,2) == story);
   wavep = wf{wavcnt}(round(TIS*fs-eppre*fs):round(TIS*fs+epw*fs));
   
   % epoch the meg file (audio):
   trinx = find([event.value] == story);
   trinx = event(trinx(story_part)+1).sample;   
   MEGep = audch.trial{1}(round(trinx+TIS*fs-eppre*fs):round(trinx+TIS*fs+epw*fs));
   
   %close all
   %plot(wavep./max(wavep));
   %hold on
   %plot(MEGep./max(MEGep)+1);
   
   % cross-correlation
   [xc, lags] = xcorr(wavep, MEGep,'normalized');   
   [mv minx] = max(xc);
   cor = lags(minx);
   
   samfin = trinx+TIS*fs-cor;
   MEGep = audch.trial{1}(round(samfin-eppre*fs):round(samfin+epw*fs));
   
   % crosscorrelation check that now at 0
   [xc, lags] = xcorr(wavep, MEGep,'normalized');   
   [mv minx] = max(xc);
   if abs(lags(minx)) > 2
       warning('wrong lag')
   end   
   if mv < 0.5
       warning('low correlation')
   end
   
   % put info's together as a trial
   strl =[round(sample+pre); round(sample+post); pre; cntword; wordcode; story; story_part; condition; first_occ; wordOrder; cor];
   trl = [trl; strl'];
end
end