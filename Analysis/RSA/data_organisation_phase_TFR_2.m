function [cell_RSA] = data_organisation_phase_TFR_2(TFR,freqwin,channels,time_pro,time_ref,bas,split_band,subj)

TFR150 = TFR;
subj = erase(subj,'sub');
subj = str2num(subj);

% add onset into trialinfo
trialinfo = TFR150.trialinfo;
% identify unfit pronouns (aka jou)
jou = [77;593;684];
[C,It1,Ij] = intersect(trialinfo(:,1),jou); % It = indices of numbers in C
% identify mis-included adjectives
adj = [948;972;1017;1019;1207;797;930;928;802;864;999;799;904];
[C,It2,Ij] = intersect(trialinfo(:,1),adj); % It = indices of numbers in C

baseloc = '/project/3027010.01/';
Info = readtable([baseloc 'wordinfo_nounRef_new_v2.csv']);
for cnt = 1:height(trialinfo)
    wordcnt = trialinfo(cnt,1);
    ind_trl = find(Info.count == wordcnt);
    onset = Info.start(ind_trl);
    trialinfo(cnt,10) = onset;
end

%% ref-pro
% condition matrix
inx_pro = find(trialinfo(:,5)==1);
inx_ref = find(trialinfo(:,5)==2);

% to eliminate all unfit trials (pronouns and adjectives)
[C,It,Ij] = intersect(inx_ref,It2);
inx_ref(It) = [];
[C,It,Ij] = intersect(inx_pro,It1);
inx_pro(It) = [];

TFR150.inx_pro = inx_pro;
TFR150.inx_ref = inx_ref;
% same story or not
refstory = repmat(trialinfo(:,3),[1 length(trialinfo(:,3))]);
samestory = (refstory == refstory');
% same part or not
part = repmat(trialinfo(:,4),[1 length(trialinfo(:,4))]);
samepart = samestory & (part == part');
% same reference or not
refcode = repmat(trialinfo(:,2),[1 length(trialinfo(:,2))]);
sameitMat = (refcode == refcode');
sameitMat = double(sameitMat);
sameitMat(logical(eye(size(sameitMat)))) = -1;
sameitMat(samestory==0) = -1;
%% timing - to exclude temporally close trial pairs where words match
onset = repmat(trialinfo(:,10),[1 length(trialinfo(:,10))]);
timing = onset - onset';
timing((timing>0) & (timing<2) & (samepart==1)) = 1;
sameitMat_following = zeros(size(timing));
wordcodes_trl = cell(size(timing,2),1);
for i=1:size(timing,2)
    % find immediately following words
    closewords_inx = find(timing(:,i)==1);
    % find their wordcodes
    closewords_code = refcode(closewords_inx,1); % to get ref code of any word close by in time
    onset_code = refcode(i,1); % ref code of the current trial defining word
    
    for j=1:(i-1) % to look at each word before the current trial defining word
        wordcodes_strl = wordcodes_trl{j,1};
        % check if any code(s) included in the current trl i (excluding the onset word) 
        % matches those in the preceding trl j (within 2 sec)
        C1 = intersect(wordcodes_strl,closewords_code);
        % check if the ref code of the onset word of the current trl i matches that of
        % any word included in trl j
        len_wordcodes = length(wordcodes_strl);
        C2 = intersect(wordcodes_strl(2:len_wordcodes),onset_code);
        % if either satisfies, an i-j trial pair is coded as having
        % matching words that were include in the trials (which needs to be removed as a confound)
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
%% to ensure that the median word distance of matching and non-matching conditions remian the same (by removing non-matching word pairs)
% distance
reforder = repmat(trialinfo(:,7),[1 length(trialinfo(:,7))]);
dist = abs(reforder - reforder');
%dist = dist(inx_pro,inx_ref);

threshold = 1570;
dist(dist >= threshold) = -1;
%% trial definition/selection
trl_diff = (samestory==1) & (sameitMat==0) & (sameitMat_following~=1) & (dist~=-1); % criteria: same story, same referent, without randomly included words that match, mean distance kept same as matching condition
trl_same = (samestory==1) & (sameitMat==1) & (sameitMat_following~=1); % criteria: same story, same referent, but without randomly included words that match
trlinx_diff = trl_diff(inx_pro,inx_ref);
trlinx_same = trl_same(inx_pro,inx_ref);
%% data
addpath /home/lacnsg/rondin/CircStat2012a/;
cell_RSA = cell(50,50,1);
for j=1:1:(1.8/0.05) % pronoun sliding
    slidwin_pro = [-0.3 -0.25] + (j-1)*0.05; % also plot some vals before onset
    
    for k=1:1:(1.8/0.05)
        slidwin_ref = [-0.3 -0.25] + (k-1)*0.05;
        set_data = TFresult_chunking_phase(TFR150,slidwin_pro,slidwin_ref,freqwin,split_band,channels);
        
        for l=1:size(set_data.results,2) % length = num of freq
            data_pro = set_data.results{1,l};
            data_ref = set_data.results{2,l};
            % RSA
            CorMat = circ_corrcc_mat(data_pro, data_ref);
            % transform the data into columns (value, condition, participant)
            dp_same = mean(CorMat(trlinx_same)); % 20210728: only mean is taken into the next level
            dp_same(:,2) = 1; % condition
            dp_same(:,3) = subj; % participant id
            dp_diff = mean(CorMat(trlinx_diff));
            dp_diff(:,2) = 0; % condition
            dp_diff(:,3) = subj; % participant id
            dbl = [dp_same;dp_diff];
            % save the result
            dbl_org = cell_RSA{j,k,l};
            cell_RSA{j,k,l} = [dbl_org;dbl];
        end
    end
end

end

