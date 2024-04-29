function [set_data] = TFresult_chunking_phase(TFresult,timwin_pro,timwin_ref,freqwin,split,channels)
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
ind_start_pro = find(round(TFresult.time,2) == round(timwin_pro(1),2));
ind_stop_pro = find(round(TFresult.time,2) == round(timwin_pro(2),2));
timlen_pro = ind_stop_pro - ind_start_pro + 1;
% transform timwin_ref
ind_start_ref = find(round(TFresult.time,2) == round(timwin_ref(1),2));
ind_stop_ref = find(round(TFresult.time,2) == round(timwin_ref(2),2));
timlen_ref = ind_stop_ref - ind_start_ref + 1;
%start_ref = TFresult.time(ind_start);
%stop_ref = TFresult.time(ind_stop);

% transform freq range
ind_start_freq = find(round(TFresult.freq) == freqwin(1));
ind_stop_freq = find(round(TFresult.freq) == freqwin(2));
% split into lower- and higher-gamma (half & half)
mid_freq = round((ind_start_freq + ind_stop_freq)/2);

% find and transform channels into indices
if channels == 'all'
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
ind_pro = TFresult.inx_pro;
ind_ref = TFresult.inx_ref;

% slice the TFresults
result_all = TFresult.fourierspctrm;
cell = {}; % to save the 2D-matrix (datapoints*trials) of each frequency

% pack gamma freq's into groups if needed
freq_inx = ind_start_freq:ind_stop_freq;
if strcmp(split,'split') == 1
    ind_freq1 = ind_start_freq:mid_freq;
    ind_freq2 = mid_freq:ind_stop_freq;
    freq_inx = [ind_freq1;ind_freq2];
end

for i=1:height(freq_inx)
    % pronouns
    freqs = freq_inx(i,:);
    trl = [];
    for j=1:length(ind_pro)
        ind = ind_pro(j);
        strl = reshape(result_all(ind,inx_chan,freqs,ind_start_pro:ind_stop_pro), [length(inx_chan)*timlen_pro*length(freqs) 1]);
        trl = [trl strl];
    end
    cell{1,i} = trl; % first row: pronouns
    
    % referents
    trl = [];
    for j=1:length(ind_ref)
        ind = ind_ref(j);
        strl = reshape(result_all(ind,inx_chan,freqs,ind_start_ref:ind_stop_ref), [length(inx_chan)*timlen_ref*length(freqs) 1]);
        trl = [trl strl];
    end
    cell{2,i} = trl; % second row: referents
    
end

set_data = struct();
set_data.results = cell;
set_data.freq = TFresult.freq(freq_inx);
set_data.time_pro = TFresult.time(ind_start_pro:ind_stop_pro);
set_data.time_ref = TFresult.time(ind_start_ref:ind_stop_ref);
set_data.chan = TFresult.label(inx_chan');
set_data.inx_pro = ind_pro;
set_data.inx_ref = ind_ref;
set_data.trialinfo = TFresult.trialinfo;
end

