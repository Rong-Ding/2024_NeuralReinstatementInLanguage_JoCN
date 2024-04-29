function [set_basl] = baseline_comp(set_data,tim_pro,tim_ref)
% baseline computation (use this only AFTER having the chunked baseline data!)

%   set_data: a struct as the product of computation of TFresult_chunking
%   output: cell_bas is a 3 * num of freq cell variable

cell_bas = {};
cell = set_data.results;
for i=1:height(set_data.freq) % 20211026: need to take all freqs into account
    freqs = set_data.freq(i,:);
    trls_pro = cell{1,i};
    trls_ref = cell{2,i};
    
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
    
    cell_bas{1,i} = repmat(bas_pro,[tim_pro 1]); % baseline pronoun trls
    cell_bas{2,i} = repmat(bas_ref,[tim_ref 1]); % baseline referent trls
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

