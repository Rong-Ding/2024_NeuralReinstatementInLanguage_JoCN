%%
TimingInfo = readtable('/project/3027010.01/wordinfo_nounRef_new_v2.csv.csv');
inx_jou = [find(strcmp(TimingInfo.word(:),'jou'));find(strcmp(TimingInfo.word(:),'gouden'));find(strcmp(TimingInfo.word(:),'prachtige'));find(strcmp(TimingInfo.word(:),'oudste'));find(strcmp(TimingInfo.word(:),'tweede'));find(strcmp(TimingInfo.word(:),'derde'));find(strcmp(TimingInfo.word(:),'twee'));find(strcmp(TimingInfo.word(:),'anderen'));find(strcmp(TimingInfo.word(:),'oudsten'))];
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
timing((timing>0) & (timing<2) & (samepart==1)) = 1;
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

%%
trl_diff = (samestory==1) & (sameitMat==0) & (sameitMat_following~=1);
trl_same = (samestory==1) & (sameitMat==1) & (sameitMat_following~=1);
trlinx_diff = trl_diff(inx_pro,inx_ref);
trlinx_same = trl_same(inx_pro,inx_ref);
%% stats
% distance
reforder = repmat(TimingInfo.wordOrder(:),[1 length(TimingInfo.wordOrder(:))]);
dist = abs(reforder - reforder');
dist = dist(inx_pro,inx_ref);

same = dist(trlinx_same); % 5801
diff = dist(trlinx_diff); % 80647

[p,h,stats_rank] = ranksum(same,diff);


%% find the optimal point where no difference between means
%same = dist(sameitMat);
med_same = median(same); % 671

threshold = 4000; % the smallest distance between pronoun and nonreferent
med_diff = median(diff);

while med_diff > med_same
    
    threshold = threshold - 1; % 1570
    dist(trlinx_diff & dist >= threshold) = -1;
    
    %same = dist(sameitMat);
    diff = dist(trlinx_diff & dist~=-1); % 61589
    med_diff = median(diff);
    %[p,h,stats] = ranksum(same,diff);
    
end
