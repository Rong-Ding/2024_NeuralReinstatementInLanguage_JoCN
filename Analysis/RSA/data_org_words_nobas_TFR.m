function [cell_RSA_ref,cell_RSA_pro] = data_org_words_nobas_TFR(TFR,freqwin,channels,time1,time2,bas,split_band,subj)


TFR150 = TFR;
subj = erase(subj,'sub');
subj = str2num(subj);

% baseline - for trialinfo only
%[set_basl] = TFresult_chunking(TFR150,bas,bas,freqwin,split_band,channels);
%[set_basl] = baseline_comp(set_basl,time1,time2);

% add wordID into trialinfo
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
    wordID = Info.wordID(ind_trl);
    trialinfo(cnt,9) = wordID;
    onset = Info.start(ind_trl);
    trialinfo(cnt,10) = onset;
    
end

inx_pro = find(trialinfo(:,5)==1);
inx_ref = find(trialinfo(:,5)==2);

% to eliminate all unfit trials (pronouns and adjectives)
[C,It,Ij] = intersect(inx_ref,It2);
inx_ref(It) = [];
[C,It,Ij] = intersect(inx_pro,It1);
inx_pro(It) = [];

TFR150.inx_pro = inx_pro;
TFR150.inx_ref = inx_ref;
% condition mats
% referents
id_ref = repmat(trialinfo(inx_ref,9),[1 length(inx_ref)]);
sameitMat_ref = (id_ref == id_ref');
% same story or not
code_ref = repmat(trialinfo(inx_ref,3),[1 length(inx_ref)]);
sameitMat_refstory = (code_ref == code_ref');
sameitMat_ref = double(sameitMat_ref);
sameitMat_ref(logical(eye(size(sameitMat_ref)))) = -1; % diagonal vals put into -1
sameitMat_ref(sameitMat_refstory==0) = -1;
% same part of not
part_ref = repmat(trialinfo(inx_ref,4),[1 length(inx_ref)]);
samepart_ref = (sameitMat_refstory == sameitMat_refstory') & (part_ref == part_ref');
% timing
onset_ref = repmat(trialinfo(inx_ref,10),[1 length(inx_ref)]);
timing_ref = onset_ref - onset_ref';
timing_ref((timing_ref>0) & (timing_ref<2) & (samepart_ref==1)) = 1;

sameitMat_following = zeros(size(timing_ref));
wordcodes_trl = cell(size(timing_ref,2),1);
for i=1:size(timing_ref,2)
    % find immediately following words
    closewords_inx = find(timing_ref(:,i)==1);
    % find their wordcodes
    closewords_code = code_ref(closewords_inx,1); % shape
    onset_code = code_ref(i,1);
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
% distance
reforder_ref = repmat(trialinfo(inx_ref,7),[1 length(inx_ref)]);
dist_ref = abs(reforder_ref - reforder_ref');
dist_ref(sameitMat_ref==0 & dist_ref >= 1416) = -1;
% trial selection
trlinx_diff_ref = (sameitMat_refstory==1) & (sameitMat_ref==0) & (sameitMat_following~=1) & (dist_ref~=-1);% criteria: same story, same referent, without randomly included words that match, mean distance kept same as matching condition
trlinx_same_ref = (sameitMat_refstory==1) & (sameitMat_ref==1) & (sameitMat_following~=1);% criteria: same story, same referent, but without randomly included words that match

% pronouns
id_pro = repmat(trialinfo(inx_pro,9),[1 length(inx_pro)]);
sameitMat_pro = (id_pro == id_pro');
% same story or not
code_pro = repmat(trialinfo(inx_pro,3),[1 length(inx_pro)]);
sameitMat_prostory = (code_pro == code_pro');
sameitMat_pro = double(sameitMat_pro);
sameitMat_pro(logical(eye(size(sameitMat_pro)))) = -1; % diagonal vals put into -1
sameitMat_pro(sameitMat_prostory==0) = -1;
% same part of not
part_pro = repmat(trialinfo(inx_pro,4),[1 length(inx_pro)]);
samepart_pro = (sameitMat_prostory == sameitMat_prostory') & (part_pro == part_pro');
% timing
onset_pro = repmat(trialinfo(inx_pro,10),[1 length(inx_pro)]);
timing_pro = onset_pro - onset_pro';
timing_pro((timing_pro>0) & (timing_pro<2) & samepart_pro) = 1;
sameitMat_following = zeros(size(timing_pro));
wordcodes_trl = cell(size(timing_pro,2),1);
for i=1:size(timing_pro,2)
    % find immediately following words
    closewords_inx = find(timing_pro(:,i)==1);
    % find their wordcodes
    closewords_code = code_pro(closewords_inx,1); % shape
    onset_code = code_pro(i,1);
    for j=1:(i-1)
        wordcodes_strl = wordcodes_trl{j,1};
        
        C1 = intersect(wordcodes_strl,closewords_code);

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
reforder_pro = repmat(TFR150.trialinfo(inx_pro,7),[1 length(inx_pro)]);
dist_pro = abs(reforder_pro - reforder_pro');
dist_pro(sameitMat_pro==0 & dist_pro >= 2385) = -1;
% trial selection
trlinx_diff_pro = (sameitMat_prostory==1) & (sameitMat_pro==0) & (sameitMat_following~=1) & (dist_pro~=-1);
trlinx_same_pro = (sameitMat_prostory==1) & (sameitMat_pro==1) & (sameitMat_following~=1);

% data
cell_RSA_ref = cell(50,50,1);
cell_RSA_pro = cell(50,50,1);
for j=1:(1.8/0.05) 
    disp(j);
    win1 = [-0.3 -0.25] + (j-1)*0.05;
    for k=j:(1.8/0.05)
        disp(k);
        win2 = [-0.3 -0.25] + (k-1)*0.05;
        set_data = TFresult_chunking_words(TFR150,win1,win2,freqwin,channels,split_band);
        
        for l=1:size(set_data.results,2) % length = num of freq
            % baseline correction
            %basl_pro = set_basl.results{1,l};
            %basl_ref = set_basl.results{2,l};
            data_pro1 = set_data.results{1,l}(:,inx_pro);
            data_ref1 = set_data.results{1,l}(:,inx_ref);
            data_pro2 = set_data.results{2,l}(:,inx_pro);
            data_ref2 = set_data.results{2,l}(:,inx_ref);
            % RSA: referent
            CorMat_ref = corr(data_ref1, data_ref2, 'type', 'Spearman');
            % RSA: pronoun
            CorMat_pro = corr(data_pro1, data_pro2, 'type', 'Spearman');
            
            % transform the data into columns (value, condition, participant)
            % ref
            dp_diff = mean(CorMat_ref(trlinx_diff_ref));
            dp_diff(:,2) = 0; % condition
            dp_diff(:,3) = subj; % participant id
            dp_same = mean(CorMat_ref(trlinx_same_ref)); % 20210728: only mean is taken into the next level
            dp_same(:,2) = 1; % condition
            dp_same(:,3) = subj; % participant id
            dbl = [dp_same;dp_diff];
            % save the result
            dbl_org = cell_RSA_ref{j,k,l};
            cell_RSA_ref{j,k,l} = [dbl_org;dbl];
            
            % pro
            dp_diff = mean(CorMat_pro(trlinx_diff_pro));
            dp_diff(:,2) = 0; % condition
            dp_diff(:,3) = subj; % participant id
            dp_same = mean(CorMat_pro(trlinx_same_pro)); % 20210728: only mean is taken into the next level
            dp_same(:,2) = 1; % condition
            dp_same(:,3) = subj; % participant id
            dbl = [dp_same;dp_diff];
            % save the result
            dbl_org = cell_RSA_pro{j,k,l};
            cell_RSA_pro{j,k,l} = [dbl_org;dbl];
        end
    end   
end

end

