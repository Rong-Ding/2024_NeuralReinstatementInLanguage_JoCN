function [set_data] = TFresult_chunking_words_phase(TFresult,timwin1,timwin2,freqwin,channels,split_band)
% to sort out the TF results used in an RSA

%   TFresult: a struct containing powerspectrum values as well as
%   trialinfo, time, freq, channel labels, etc.
%   timwin_pro: time window of interest for pronouns, with a form of [t1
%   t2] (s)
%   timwin_ref: time window of interest for referents, with a form of [t1
%   t2] (s)
%   freqwin: frequency range of interest, in the form [f1 f2] (Hz)
%   channels: channels of interest, a string or an array, e.g. ['T', 
%   'O','P','F','C'], 'all'


% transform timwin_pro
ind_start1 = find(round(TFresult.time,2) == round(timwin1(1),2));
ind_stop1 = find(round(TFresult.time,2) == round(timwin1(2),2));
timlen1 = ind_stop1 - ind_start1 + 1;
% transform timwin_ref
ind_start2 = find(round(TFresult.time,2) == round(timwin2(1),2));
ind_stop2 = find(round(TFresult.time,2) == round(timwin2(2),2));
timlen2 = ind_stop2 - ind_start2 + 1;
%start_ref = TFresult.time(ind_start);
%stop_ref = TFresult.time(ind_stop);

% transform freq range
ind_start_freq = find(round(TFresult.freq) == freqwin(1));
ind_stop_freq = find(round(TFresult.freq) == freqwin(2));
mid_freq = round((ind_start_freq + ind_stop_freq)/2);

% find and transform channels into indices
if strcmp(channels,'all') == 1
    inx_chan = 1:1:length(TFresult.label);
else
    inx_all = zeros(length(TFresult.label),1);
    for i=1:length(channels)
        symb = channels(i); % e.g., "T","LT"
        inx = contains(TFresult.label,symb);
        inx_all = inx_all | inx;
    end
    inx_chan = inx_all .* (1:1:length(TFresult.label))';
    inx_chan = (inx_chan(inx_chan>0))';
end

% find the indices for pronouns and referents respectively
ind_pro = find(TFresult.trialinfo(:,5)==1);
ind_ref = find(TFresult.trialinfo(:,5)==2);

% slice the TFresults
result_all = TFresult.fourierspctrm;
cell = {}; % to save the 2D-matrix (datapoints*trials) of each frequency
freq_inx = ind_start_freq:ind_stop_freq;
if strcmp(split_band,'split') == 1
    ind_freq1 = ind_start_freq:mid_freq;
    ind_freq2 = mid_freq:ind_stop_freq;
    freq_inx = [ind_freq1;ind_freq2];
end

for i=1:height(freq_inx)
    
    freqs = freq_inx(i,:);
    
    % time window 1
    trl = [];
    for j=1:height(TFresult.trialinfo)
        strl = reshape(result_all(j,inx_chan,freqs,ind_start1:ind_stop1), [length(inx_chan)*timlen1*length(freqs) 1]);
        trl = [trl strl];
    end
    cell{1,i} = trl;
    
    % time window 2
    trl = [];
    for j=1:height(TFresult.trialinfo)
        strl = reshape(result_all(j,inx_chan,freqs,ind_start2:ind_stop2), [length(inx_chan)*timlen2*length(freqs) 1]);
        trl = [trl strl];
    end
    cell{2,i} = trl;
    %cell{2,i} = angle(trl);
    
end

set_data = struct();
set_data.results = cell;
set_data.freq = TFresult.freq(freq_inx);
set_data.time_pro = TFresult.time(ind_start1:ind_stop1);
set_data.time_ref = TFresult.time(ind_start2:ind_stop2);
set_data.chan = TFresult.label(inx_chan');
set_data.inx_pro = TFresult.inx_pro; % 2021/12/03
set_data.inx_ref = TFresult.inx_ref;
set_data.trialinfo = TFresult.trialinfo;
end