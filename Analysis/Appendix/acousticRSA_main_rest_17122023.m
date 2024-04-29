function [flag] = acousticRSA_main_rest_17122023(num)

%%
addpath('/home/common/matlab/fieldtrip');
ft_defaults;

%%
TimingInfo = readtable('/project/3027010.01/wordinfo_nounRef_new_v2.csv');
inx_jou = [find(TimingInfo.Var1(:)==629);find(TimingInfo.Var1(:)==630);find(strcmp(TimingInfo.word(:),'jou'));find(strcmp(TimingInfo.word(:),'gouden'));find(strcmp(TimingInfo.word(:),'prachtige'));find(strcmp(TimingInfo.word(:),'oudste'));find(strcmp(TimingInfo.word(:),'tweede'));find(strcmp(TimingInfo.word(:),'derde'));find(strcmp(TimingInfo.word(:),'twee'));find(strcmp(TimingInfo.word(:),'anderen'));find(strcmp(TimingInfo.word(:),'oudsten'))];
TimingInfo(inx_jou,:) = [];
%%
inx_pro = find(strcmp(TimingInfo.condition(:),'pronoun'));
inx_ref = find(strcmp(TimingInfo.condition(:),'referent'));
%% for generating sameitMat
% same story or not
refstory = repmat(TimingInfo.story(:),[1 length(TimingInfo.story(:))]);
samestory = (refstory == refstory');
% same part or not
part = repmat(TimingInfo.part(:),[1 length(TimingInfo.part(:))]);
samepart = samestory & (part == part');
% same reference or not
refcode = repmat(TimingInfo.code(:),[1 length(TimingInfo.code(:))]);
sameitMat = (refcode == refcode');
sameitMat = double(sameitMat);
sameitMat(logical(eye(size(sameitMat)))) = -1;
sameitMat(samestory==0) = -1;

%% timing
onset = repmat(TimingInfo.start(:),[1 length(TimingInfo.start(:))]);
timing = onset - onset';
timing((timing>0) & (timing<1.5) & (samepart==1)) = 1;
sameitMat_following = zeros(size(timing));
wordcodes_trl = cell(size(timing,2),1);
for i=1:size(timing,2)
    % find immediately following words
    closewords_inx = find(timing(:,i)==1);
    % find their wordcodes
    closewords_code = refcode(closewords_inx,1); % shape
    onset_code = refcode(i,1);
    for j=1:(i-1)
        wordcodes_strl = wordcodes_trl{j,1};
        
        % check if any code of the current trl i matches that of preceding
        % trl j
        C1 = intersect(wordcodes_strl,closewords_code);
        % check if the onset of the current trl i matches codes of
        % following words of trl j
        len_wordcodes = length(wordcodes_strl);
        C2 = intersect(wordcodes_strl(2:len_wordcodes),onset_code);
        if (isempty(C1) == 0) || (isempty(C2) == 0)
            sameitMat_following(j,i) = 1;
            %disp(closewords_code);
        end
    end
    % add code of onset word into wordcodes of current trial
    closewords_code = [onset_code;closewords_code];
    % save the wordcodes in each trial for searching matching
    % following-words
    wordcodes_trl{i,1} = closewords_code;
end
sameitMat_following = sameitMat_following | sameitMat_following';

% distance
reforder = repmat(TimingInfo.wordOrder(:),[1 length(TimingInfo.wordOrder(:))]);
dist = abs(reforder - reforder');
threshold = 1757;
dist(dist >= threshold) = -1;

%
trl_diff = (samestory==1) & (sameitMat==0) & (sameitMat_following~=1) & (dist~=-1);
trl_same = (samestory==1) & (sameitMat==1) & (sameitMat_following~=1);
trlinx_diff = trl_diff(inx_pro,inx_ref);
trlinx_same = trl_same(inx_pro,inx_ref);

%% parse wav files and generate trials
baseloc = '/project/3027010.01/';
stotype = [1 2 3 4 1 2 1 2 3;1 1 1 1 3 3 2 2 2]';
allwavs = dir([baseloc '*.wav']);
wf = cell(1,9);
for cntwav = 1:length(allwavs)
   [wf1, fs_wav] = audioread([allwavs(cntwav).folder '/' allwavs(cntwav).name]);
   wf{1,cntwav} = wf1;
end
fs = fs_wav;

wav_data = struct();
wav_data.label = {'wav'};
wav_data.fsample = fs_wav;

short_trls = [];
sampleinfo = [];
trl = [];
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
   
   eppre = -0.5;
   epw = 1.5;
   % epoch the wav file:
   wavcnt = find(stotype(:,1) == story_part & stotype(:,2) == story);
   if (round(TIS*fs+epw*fs) <= length(wf{1,wavcnt})) && (round(TIS*fs+eppre*fs) >= 0)
       wavep = wf{1,wavcnt}(round(TIS*fs+eppre*fs):round(TIS*fs+epw*fs));
       wav_data.trial{1,cntword} = wavep';
       wav_data.time{1,cntword} = eppre:1/fs:epw;
   else
       short_trls = [short_trls;cntword];
       continue
   end
   % put info's together as a trial
   strl =[cntword; wordcode; story; story_part; condition; first_occ; wordOrder];
   trl = [trl; strl'];
   
   sample = [round(TIS*fs-eppre*fs); round(TIS*fs+epw*fs)];
   sampleinfo = [sampleinfo;sample'];
   
end

wav_data.trialinfo = trl;
wav_data.sampleinfo = sampleinfo;

%% compute spectrogram per time frame
t = -0.5:0.05:1.45;
t_p = [-0.5:0.05:-0.05;0:0.05:0.45;0.5:0.05:0.95;1:0.05:1.45];% time axis
%t_pro = t_pro(num,:);
Fs = fs;
Nspec = 0.05*Fs;
wspec = hamming(Nspec);
Noverlap = round(Nspec/2);
freqRange = 20:fs/2;
%%
cell_RSA = cell(60,60);
%%
for num=2:4
    t_pro = t_p(num,:);
    wincnt_pro=length(t_pro);
    timwin_pro = [t_pro(wincnt_pro) t_pro(wincnt_pro)+0.05];
    disp(timwin_pro);
    inx_tp_pro = find((wav_data.time{1,1}(:)>=timwin_pro(1)) & (wav_data.time{1,1}(:)<=timwin_pro(2)));
    mat_pro = [];
    for trlcont=1:height(inx_pro)
        [S,f,T,ps] = spectrogram(wav_data.trial{1,inx_pro(trlcont)}(inx_tp_pro),wspec,Noverlap,freqRange,Fs,'power');
        %disp(T);
        mat_pro = [mat_pro ps(:)];
    end
    
    for wincnt_ref=1:length(t)-1
        timwin_ref = [t(wincnt_ref) t(wincnt_ref+1)];
        disp(timwin_ref);
        inx_tp_ref = find((wav_data.time{1,1}(:)>=timwin_ref(1)) & (wav_data.time{1,1}(:)<=timwin_ref(2)));
        mat_ref = [];
        for trlcont=1:height(inx_ref)
            [S,f,T,ps] = spectrogram(wav_data.trial{1,inx_ref(trlcont)}(inx_tp_ref),wspec,Noverlap,freqRange,Fs,'power');
            %disp(T);
            mat_ref = [mat_ref ps(:)];
        end
        CorMat = corr(mat_pro, mat_ref, 'type', 'Spearman');
        % transform the data into columns (value, condition, participant)
        dp_same = nanmean(CorMat(trlinx_same)); % 20210728: only mean is taken into the next level
        dp_same(:,2) = 1; % condition
        %dp_same(:,3) = subj; % participant id
        dp_diff = nanmean(CorMat(trlinx_diff));
        dp_diff(:,2) = 0; % condition
        %dp_diff(:,3) = subj; % participant id
        dbl = [dp_same;dp_diff];
        % save the result
        dbl_org = cell_RSA{wincnt_pro,wincnt_ref};
        cell_RSA{wincnt_pro*num,wincnt_ref} = [dbl_org;dbl];
    end

end

%%
for rownum = 40 % 30, 40
    for col=1:39
        dbl_org = cell_RSA{rownum,col};
        dbl_org(1:2,:) = [];   
        cell_RSA{rownum,col} = dbl_org;
    end
end

%% save file
datafile = '/project/3027010.01/middata/Corr/acoustic_12122023/RSA_acoustic_all.mat';
save(datafile,'cell_RSA','-v7.3');

%% add last column of referent
for wincnt_ref=length(t)
    timwin_ref = [t(wincnt_ref) t(wincnt_ref)+0.05];
    disp(timwin_ref);
    inx_tp_ref = find((wav_data.time{1,1}(:)>=timwin_ref(1)) & (wav_data.time{1,1}(:)<=timwin_ref(2)));
    mat_ref = [];
    for trlcont=1:height(inx_ref)
        [S,f,T,ps] = spectrogram(wav_data.trial{1,inx_ref(trlcont)}(inx_tp_ref),wspec,Noverlap,freqRange,Fs,'power');
        %disp(T);
        mat_ref = [mat_ref ps(:)];
    end
    
    for wincnt_pro=1:length(t)
        timwin_pro = [t(wincnt_pro) t(wincnt_pro)+0.05];
        disp(timwin_pro);
        inx_tp_pro = find((wav_data.time{1,1}(:)>=timwin_pro(1)) & (wav_data.time{1,1}(:)<=timwin_pro(2)));
        mat_pro = [];
        for trlcont=1:height(inx_pro)
            [S,f,T,ps] = spectrogram(wav_data.trial{1,inx_pro(trlcont)}(inx_tp_pro),wspec,Noverlap,freqRange,Fs,'power');
            %disp(T);
            mat_pro = [mat_pro ps(:)];
        end
        CorMat = corr(mat_pro, mat_ref, 'type', 'Spearman');
        % transform the data into columns (value, condition, participant)
        dp_same = nanmean(CorMat(trlinx_same)); % 20210728: only mean is taken into the next level
        dp_same(:,2) = 1; % condition
        %dp_same(:,3) = subj; % participant id
        dp_diff = nanmean(CorMat(trlinx_diff));
        dp_diff(:,2) = 0; % condition
        %dp_diff(:,3) = subj; % participant id
        dbl = [dp_same;dp_diff];
        % save the result
        dbl_org = cell_RSA{wincnt_pro,wincnt_ref};
        cell_RSA{wincnt_pro,wincnt_ref} = [dbl_org;dbl];
    end

end

%%
flag = 'done';
end

