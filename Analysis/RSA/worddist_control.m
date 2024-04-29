%%
TimingInfo = readtable('/project/3027010.01/wordinfo_nounRef_new_v2.csv');
inx_jou = [find(strcmp(TimingInfo.word(:),'jou'));find(strcmp(TimingInfo.word(:),'gouden'));find(strcmp(TimingInfo.word(:),'prachtige'));find(strcmp(TimingInfo.word(:),'oudste'));find(strcmp(TimingInfo.word(:),'tweede'));find(strcmp(TimingInfo.word(:),'derde'));find(strcmp(TimingInfo.word(:),'twee'));find(strcmp(TimingInfo.word(:),'anderen'));find(strcmp(TimingInfo.word(:),'oudsten'))];
TimingInfo(inx_jou,:) = [];
%%
inx_pro = find(strcmp(TimingInfo.condition(:),'pronoun'));
inx_ref = find(strcmp(TimingInfo.condition(:),'referent'));
% distance
reforder_pro = repmat(TimingInfo.wordOrder(inx_pro),[1 length(inx_pro)]);
reforder_ref = repmat(TimingInfo.wordOrder(inx_ref),[1 length(inx_ref)]);
dist_pro = abs(reforder_pro - reforder_pro');
dist_ref = abs(reforder_ref - reforder_ref');
% same story or not
refstory_pro = repmat(TimingInfo.story(inx_pro),[1 length(inx_pro)]);
refstory_ref = repmat(TimingInfo.story(inx_ref),[1 length(inx_ref)]);
samestory_pro = (refstory_pro == refstory_pro');
samestory_ref = (refstory_ref == refstory_ref');
% same part of not
part_pro = repmat(TimingInfo.part(inx_pro),[1 length(inx_pro)]);
part_ref = repmat(TimingInfo.part(inx_ref),[1 length(inx_ref)]);
samepart_pro = (refstory_pro == refstory_pro') & (part_pro == part_pro');
samepart_ref = (refstory_ref == refstory_ref') & (part_ref == part_ref');
% same word or not
code_pro = repmat(TimingInfo.wordID(inx_pro),[1 length(inx_pro)]);
code_ref = repmat(TimingInfo.wordID(inx_ref),[1 length(inx_ref)]);
sameitMat_pro = (code_pro == code_pro');
sameitMat_pro = double(sameitMat_pro);
sameitMat_pro(logical(eye(size(sameitMat_pro)))) = -1;
sameitMat_pro(samestory_pro==0) = -1;
sameitMat_ref = (code_ref == code_ref');
sameitMat_ref = double(sameitMat_ref);
sameitMat_ref(logical(eye(size(sameitMat_ref)))) = -1;
sameitMat_ref(samestory_ref==0) = -1;
% timing
%%
% referent
onset_ref = repmat(TimingInfo.start(inx_ref),[1 length(inx_ref)]);
timing_ref = onset_ref - onset_ref';

timing_ref((timing_ref>0) & (timing_ref<2) & (samepart_ref==1)) = 1;
sameitMat_following = zeros(size(timing_ref));
wordcodes_trl = cell(size(timing_ref,2),1);
pre_ref = [];
for i=1:size(timing_ref,2)
    % check if epoch of any stim word overlaps with the current epoch
    inx_prestim = find((timing_ref(:,i)>-1.5) & (timing_ref(:,i)<0) & (samepart_ref(:,i)==1));
    if isempty(inx_prestim)
        col_pre = zeros(size(timing_ref,1),1);
    else
        col_pre = ones(size(timing_ref,1),1);
    end
    pre_ref = [pre_ref col_pre];
    % find immediately following words
    closewords_inx = find(timing_ref(:,i)==1);
    % find their wordcodes
    closewords_code = code_ref(closewords_inx,1); % shape
    onset_code = code_ref(i,1);
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
%%
% result: 1 on diagonal ("kater" immediately after "kater" itself, so diag was 
% included when finding referents of 'kater')
% 18 shared by Lower and Upper triangulars: because one 'hoedje' is followed by
% a 'ransel', and another 'ransel' is followed by a 'hoedje'
trlinx_diff_ref = (samestory_ref==1) & (sameitMat_ref==0) & (sameitMat_following~=1);
trlinx_same_ref = (samestory_ref==1) & (sameitMat_ref==1) & (sameitMat_following~=1) & ~(timing_ref<2 & timing_ref>-2 & samepart_ref);
%%
% pronouns
onset_pro = repmat(TimingInfo.start(inx_pro),[1 length(inx_pro)]);
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

%trlinx_diff_pro = (samestory_pro==1) & (sameitMat_pro==0) & (sameitMat_following~=1)  & (timing_pro>=2 | timing_pro<=-2);
trlinx_diff_pro = (samestory_pro==1) & (sameitMat_pro==0) & (sameitMat_following~=1) & ~(timing_pro<2 & timing_pro>-2 & samepart_pro);
trlinx_same_pro = (samestory_pro==1) & (sameitMat_pro==1) & (sameitMat_following~=1) & ~(timing_pro<2 & timing_pro>-2 & samepart_pro);
%trlinx_same_pro = (samestory_pro==1) & (sameitMat_pro==1) & (sameitMat_following~=1) & (timing_pro>=2 | timing_pro<=-2);
%% stats ref

dist_ref(samestory_ref==0) = -1;
dist_ref(logical(eye(size(dist_ref)))) = -1;
same_ref = dist_ref(trlinx_same_ref & dist_ref~=-1); % 3990
diff_ref = dist_ref(trlinx_diff_ref & dist_ref~=-1); % 51340

[p_ref,h_ref,stats_ref_rank] = ranksum(same_ref,diff_ref);

%% stats pro
dist_pro(samestory_pro==0) = -1;
dist_pro(logical(eye(size(dist_pro)))) = -1;
same_pro = dist_pro(trlinx_same_pro & dist_pro~=-1); % 23848
diff_pro = dist_pro(trlinx_diff_pro & dist_pro~=-1); % 159154

[p_pro,h_pro,stats_pro_rank] = ranksum(same_pro,diff_pro);

%% referent: threshold - same median
%same_ref = dist_ref(sameitMat_ref==1 & dist_ref~=-1); % 4002
med_same_ref = median(same_ref); % 593

threshold_ref = 4000; % the smallest distance between pronoun and nonreferent
%dist_ref(samestory_ref==0) = -1;
med_diff_ref = median(diff_ref);

while med_diff_ref > med_same_ref
    
    threshold_ref = threshold_ref - 1; % final = 1416
    dist_ref(trlinx_diff_ref & dist_ref >= threshold_ref) = -1;
    
    %same = dist(sameitMat);
    diff_ref = dist_ref(trlinx_diff_ref & dist_ref~=-1); % final total num = 37886
    med_diff_ref = median(diff_ref);
    %[p,h,stats] = ranksum(same,diff);
    
end

%% pronoun: threshold - same median
%same_pro = dist_pro(sameitMat_pro==1 & dist_pro~=-1); % 27052
med_same_pro = median(same_pro); % final: 810

threshold_pro = 4000; % the smallest distance between pronoun and nonreferent
%dist_pro(samestory_pro==0) = -1;
med_diff_pro = median(diff_pro);

while med_diff_pro > med_same_pro
    
    threshold_pro = threshold_pro - 1; % final = 2385
    dist_pro(trlinx_diff_pro & dist_pro >= threshold_pro) = -1;
    
    %same = dist(sameitMat);
    diff_pro = dist_pro(trlinx_diff_pro & dist_pro~=-1); % final total num = 152358
    med_diff_pro = median(diff_pro);
    %[p,h,stats] = ranksum(same,diff);
    
end
