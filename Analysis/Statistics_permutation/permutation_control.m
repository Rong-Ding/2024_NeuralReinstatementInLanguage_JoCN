% read file
baseloc = '/project/3027010.01/middata/Corr/1208_all/control/phase/delta/';
filenames = dir([baseloc '*RSA*.mat']);
N = length(filenames);
%%
% assemble data
lst = -0.3:0.05:1.45;
sta = 0;
en = 1.45;
sta = find(round(lst(:),2) == sta);
en = find(round(lst(:),2) == en);
inx = en-sta+1;

mat_same_ref = ones(inx,inx,1,N);
mat_diff_ref = ones(inx,inx,1,N);
mat_same_pro = ones(inx,inx,1,N);
mat_diff_pro = ones(inx,inx,1,N);
for i=1:N
    % get file
    filename = [baseloc filenames(i).name];
    load(filename);
    
    % add data by element
    for j=sta:en
        for k=j:en            
            % referent
            dbl = cell_RSA_ref{j,k};
            ind_same = find(dbl(:,2) == 1);
            ind_diff = find(dbl(:,2) == 0);
            mat_same_ref(j-sta+1,k-sta+1,1,i) = dbl(ind_same,1);
            mat_diff_ref(j-sta+1,k-sta+1,1,i) = dbl(ind_diff,1);

            % pronoun
            dbl = cell_RSA_pro{j,k};
            ind_same = find(dbl(:,2) == 1);
            ind_diff = find(dbl(:,2) == 0);
            mat_same_pro(j-sta+1,k-sta+1,1,i) = dbl(ind_same,1);
            mat_diff_pro(j-sta+1,k-sta+1,1,i) = dbl(ind_diff,1);
        end
    end
end
%%
mat_diff_ref(mat_diff_ref(:,:,:,:) == 1.00) = nan;
mat_same_ref(mat_same_ref(:,:,:,:) == 1.00) = nan;
mat_diff_pro(mat_diff_pro(:,:,:,:) == 1.00) = nan;
mat_same_pro(mat_same_pro(:,:,:,:) == 1.00) = nan;
RSA_ph_rr_diff.label{1} = 'f';
RSA_ph_rr_diff.time = 0:0.05:1.45;
RSA_ph_rr_diff.freq = 0:0.05:1.45;
RSA_ph_rr_diff.dimord = 'subj_chan_time_freq';
RSA_ph_rr_same = RSA_ph_rr_diff;
RSA_ph_rr_diff.powspctrm = permute(mat_diff_ref, [4 3 1 2]);
RSA_ph_rr_same.powspctrm = permute(mat_same_ref, [4 3 1 2]);

RSA_ph_pp_diff.label{1} = 'f';
RSA_ph_pp_diff.time = 0:0.05:1.45;
RSA_ph_pp_diff.freq = 0:0.05:1.45;
RSA_ph_pp_diff.dimord = 'subj_chan_time_freq';
RSA_ph_pp_same = RSA_ph_pp_diff;
RSA_ph_pp_diff.powspctrm = permute(mat_diff_pro, [4 3 1 2]);
RSA_ph_pp_same.powspctrm = permute(mat_same_pro, [4 3 1 2]);

%% perm test
%% cfg
cfg = [];
%cfg.channel          = {'MLC12'};
cfg.avgoverchan      = 'yes';
cfg.latency          = [0 1.45];
cfg.method           = 'montecarlo';
cfg.frequency        = [0 1.45];
cfg.statistic        = 'ft_statfun_depsamplesT';
cfg.correctm         = 'cluster';
cfg.clusteralpha     = 0.05;
cfg.clusterstatistic = 'maxsum';
cfg.minnbchan        = 0;
cfg.tail             = 0;
cfg.clustertail      = 0;
cfg.alpha            = 0.05;
cfg.numrandomization = 10000;
% prepare_neighbours determines what sensors may form clusters
%cfg_neighb.method    = 'distance';
%cfg.neighbours       = ft_prepare_neighbours(cfg_neighb, RSA_ph_rp_same);

subj = N;
design = zeros(2,2*subj);
for i = 1:subj
  design(1,i) = i;
end
for i = 1:subj
  design(1,subj+i) = i;
end
design(2,1:subj)        = 1;
design(2,subj+1:2*subj) = 2;

cfg.design   = design;
cfg.uvar     = 1;
cfg.ivar     = 2;

%% run the stats
[stat_ref] = ft_freqstatistics(cfg, RSA_ph_rr_same, RSA_ph_rr_diff);
[stat_pro] = ft_freqstatistics(cfg, RSA_ph_pp_same, RSA_ph_pp_diff);

%% save stats
save('/project/3027010.01/middata/stats/sensor_pow_cntl_theta.mat','stat_ref','stat_pro','-v7.3');

%% plot tvalue figure
colormap(turbo)
imagesc(stat_ref.time, stat_ref.time, squeeze(stat_ref.stat));
hold on
contour(stat_ref.time, stat_ref.time, squeeze(stat_ref.negclusterslabelmat == 1),1,'color',[1 1 1],'linewidth',4);
set(gca,'ydir','normal')
colorbar
caxis([-3.5, 3.5]);
c = colorbar;
c.TickDirection = 'in';
%caxis([-0.005 0.005]);
c.YTick = linspace(-3,3,2);
%title('delta (1-3Hz) phase similarities: referent control (medial temp)')
%xlabel('after referent onset (s)')
%ylabel('after referent onset (s)')

%% plot rho difference figure
mat_same = mat_same_ref;
mat_diff = mat_diff_ref;
m_s = mean(mat_same,4);

m_d = mean(mat_diff,4);
m_diff = mean(m_s,4) - mean(m_d,4);
colormap(turbo)
imagesc(stat_ref.time, stat_ref.time, m_diff);
hold on
%contour(stat_ref.time, stat_ref.time, squeeze(stat_ref.posclusterslabelmat == 1),1,'color',[1 1 1],'linewidth',3);
contour(stat_ref.time, stat_ref.time, squeeze(stat_ref.posclusterslabelmat == 1),1,'color',[0.7 .7 .7],'linewidth',3);
%contour(stat_ref.time, stat_ref.time, squeeze(stat_ref.negclusterslabelmat == 1),1,'color',[1 1 1],'linewidth',3);
%contour(stat_ref.time, stat_ref.time, squeeze(stat_ref.negclusterslabelmat == 1),1,'color',[0.7 .7 .7],'linewidth',3);
set(gca,'ydir','normal')
set(gcf,'position', [100 100 560 480])
%caxis([-0.004 0.004]);
%xlabel('after referent onset (s)')
%ylabel('after referent onset (s)')
colorbar
caxis([-0.005 0.005]);
c = colorbar;
c.TickDirection = 'in';
c.YTick = linspace(-0.004,0.004,2);

%title('Same - Different')
%xlabel('after referent onset (s)')
%ylabel('after pronoun onset (s)')

%% plot rho difference figure
mat_same = mat_same_pro;
mat_diff = mat_diff_pro;
m_s = mean(mat_same,4);
m_d = mean(mat_diff,4);
m_diff = mean(m_s,4) - mean(m_d,4);
stat=stat_pro;

%% calculate mean sim
mat_same = mat_same_ref;
mat_diff = mat_diff_ref;
m_s = mean(mat_same,4);

m_d = mean(mat_diff,4);

s = mean(m_s(squeeze(stat_ref.negclusterslabelmat == 1)));
d = mean(m_d(squeeze(stat_ref.negclusterslabelmat == 1)));
%%

colormap(turbo)
imagesc(stat.time, stat.time, m_diff);
hold on
contour(stat.time, stat_ref.time, squeeze(stat.posclusterslabelmat == 1),1,'color',[0.7 .7 .7],'linewidth',3);
contour(stat.time, stat_ref.time, squeeze(stat.negclusterslabelmat == 1),1,'color',[1 1 1],'linewidth',3);
set(gca,'ydir','normal')
set(gcf,'position', [100 100 560 480])
caxis([-0.003 0.003]);
%xlabel('after referent onset (s)')
%ylabel('after referent onset (s)')
colorbar
caxis([-0.004 0.004]);
c = colorbar;
c.TickDirection = 'in';
c.YTick = linspace(-0.003,0.003,2);

%% plot - ref
imagesc(stat_ref.time, stat_ref.time, squeeze(stat_ref.stat));
hold on
%contour(stat_ref.time, stat_ref.time, squeeze(stat_ref.posclusterslabelmat == 1),1,'color',[1 1 1],'linewidth',4);
set(gca,'ydir','normal')
colorbar
title('delta (1-3Hz) phase similarities: referent control (medial temp)')
xlabel('after referent onset (s)')
ylabel('after referent onset (s)')

%% plot for same/diff
mat_same = mat_same_ref;
mat_diff = mat_diff_ref;
m_s = mean(mat_same,4);

m_d = mean(mat_diff,4);
m_diff = mean(m_s,4) - mean(m_d,4);
tiledlayout(1,3)

nexttile
imagesc(stat_ref.time, stat_ref.time, m_s);
%contour(stat_ref.time, stat_ref.time, squeeze(stat_ref.posclusterslabelmat == 1),1,'color',[1 1 1],'linewidth',4);
set(gca,'ydir','normal')
colorbar
caxis([0.30 0.322]);
xlabel('after referent onset (s)')
ylabel('after pronoun onset (s)')
title('Same word')

nexttile
imagesc(stat_ref.time, stat_ref.time, m_d);
hold on
set(gca,'ydir','normal')
c = colorbar;
%c.Label.String = "Spearman's rho";
%c.Label.FontSize = 9;
%c.Label.FontWeight = 'bold';
c.TickDirection = 'in';
c.YTick = linspace(0.30, 0.322,2);
%c.TickLabels = num2cell(0.30:0.32);
caxis([0.30 0.322]);
title('Different words');
%xlabel('after referent onset (s)')
%ylabel('after pronoun onset (s)')

nexttile
imagesc(stat_ref.time, stat_ref.time, m_diff);
hold on
contour(stat_ref.time, stat_ref.time, squeeze(stat_ref.posclusterslabelmat == 1),1,'color',[1 1 1],'linewidth',3);
%contour(stat_ref.time, stat_ref.time, squeeze(stat_ref.negclusterslabelmat == 1),1,'color',[0.7 .7 .7],'linewidth',2);
set(gca,'ydir','normal')
c = colorbar;
c.TickDirection = 'in';
caxis([-0.005 0.005]);
c.YTick = linspace(-0.005,0.005,2);

title('Same - Different')
xlabel('after referent onset (s)')
ylabel('after pronoun onset (s)')

%% plot - pro
imagesc(stat_pro.time, stat_pro.time, squeeze(stat_pro.stat));
hold on
%contour(stat_pro.time, stat_pro.time, squeeze(stat_pro.posclusterslabelmat == 1),1,'color',[1 1 1],'linewidth',4);
contour(stat_pro.time, stat_pro.time, squeeze(stat_pro.negclusterslabelmat == 1),1,'color',[1 1 1],'linewidth',4);
set(gca,'ydir','normal')
colorbar
title('delta (1-3Hz) phase similarities: pronoun control (medial temp)')
xlabel('after pronoun onset (s)')
ylabel('after pronoun onset (s)')