function [set_basl] = baseline_comp_words(set_data,time1,time2)
% baseline computation (use this only AFTER having the chunked baseline data!)

%   set_data: a struct as the product of computation of TFresult_chunking
%   output: cell_bas is a 3 * num of freq cell variable
%   time1: number of time points that counts as time window 1 to compute the
%   similarities
%   time2: number of time points that counts as time window 2 to compute the
%   similarities

cell_bas = {};
cell = set_data.results;
inx_pro = set_data.inx_pro;
inx_ref = set_data.inx_ref;
for i=1:height(set_data.freq) % in case there're different groupings of frequencies in one go
    freqs = set_data.freq(i,:);
    trls_pro = cell{1,i}(:,inx_pro);
    trls_ref = cell{2,i}(:,inx_ref);
    
    bas_pro = [];
    bas_ref = []; % distinguishes pronouns and referents as they're stored in different rows
    % pronoun and referent trls are assumed to be equally long here
    for j=1:length(freqs)
        multiple = (j-1):length(freqs):(length(set_data.time_pro)*length(freqs)-1);
        for k=1:length(set_data.chan)
            ind = multiple.*length(set_data.chan) + k;
            pro_chan = mean(trls_pro(ind,:),1); % mean baseline for each channel * trial, per freq per time
            bas_pro = [bas_pro; pro_chan];
            ref_chan = mean(trls_ref(ind,:),1);      
            bas_ref = [bas_ref; ref_chan];
        end
    end
   
    cell_bas{1,i} = repmat(bas_pro,[time1 1]); % baseline pronoun trls
    cell_bas{2,i} = repmat(bas_ref,[time2 1]); % baseline referent trls
end

set_basl = struct();
set_basl.results = cell_bas;
set_basl.freq = set_data.freq;
set_basl.time_pro = set_data.time_pro;
set_basl.time_ref = set_data.time_ref;
set_basl.chan = set_data.chan;
set_basl.inx_pro = set_data.inx_pro;
set_basl.inx_ref = set_data.inx_ref;
set_basl.trialinfo = set_data.trialinfo;
end

