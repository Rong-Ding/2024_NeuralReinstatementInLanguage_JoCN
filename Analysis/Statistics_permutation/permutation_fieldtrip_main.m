%% addpath
addpath('/home/common/matlab/fieldtrip');
ft_defaults;

%% prepare variables
% read file
baseloc = '/project/3027010.01/middata/Corr/';
filenames = dir([baseloc '*RSA*.mat']);
N = length(filenames);

% assemble data
lst = -0.3:0.05:1.45;
sta = 0;
en = 1.45;
sta = find(round(lst(:),2) == sta);
en = find(round(lst(:),2) == en);
inx = en-sta+1;

mat_same = zeros(inx,inx,1,N);
mat_diff = zeros(inx,inx,1,N);

for i=1:N
    % get file
    filename = [baseloc filenames(i).name];
    load(filename);
    
    % add data by element
    for j=sta:en
        for k=sta:en            
            dbl = cell_RSA{j,k};
            ind_same = find(dbl(:,2) == 1);
            ind_diff = find(dbl(:,2) == 0);
            
            mat_same(j-sta+1,k-sta+1,1,i) = dbl(ind_same,1); % pronoun,referent,chan,subj
            mat_diff(j-sta+1,k-sta+1,1,i) = dbl(ind_diff,1);
        end
    end
end
RSA_ph_rp_diff.label{1} = 'f';
RSA_ph_rp_diff.time = 0:0.05:1.45;
RSA_ph_rp_diff.freq = 0:0.05:1.45;
RSA_ph_rp_diff.dimord = 'subj_chan_time_freq';
RSA_ph_rp_same = RSA_ph_rp_diff;
RSA_ph_rp_diff.powspctrm = permute(mat_diff, [4 3 1 2]);
RSA_ph_rp_same.powspctrm = permute(mat_same, [4 3 1 2]);

%% record pre and post avg diff's
mat = RSA_ph_rp_same.powspctrm - RSA_ph_rp_diff.powspctrm;
%mat_pre = squeeze(mat_pre); % remove the chan dimension
mat = mat(:,squeeze(stat.posclusterslabelmat == 1));
mat_post = mean(mat,2);

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
[stat] = ft_freqstatistics(cfg, RSA_ph_rp_same, RSA_ph_rp_diff);

%% plot
imagesc(stat.time, stat.time, squeeze(stat.stat));
%imagesc(stat.time, stat.time, squeeze(stat.stat));
hold on
contour(stat.time, stat.time, squeeze(stat.posclusterslabelmat == 1),1,'color',[1 1 1],'linewidth',2);
%contour(stat.time, stat.time, squeeze(stat.negclusterslabelmat == 1),1,'color',[1 1 1],'linewidth',2);
set(gca,'ydir','normal')
colorbar
caxis([-4, 4]);
%c.label = "Spearman's rho";
title('delta (1-3Hz) phase similarities: referent-pronoun (temporal channels)')
xlabel('after referent onset (s)')
ylabel('after pronoun onset (s)')

%% save stats
save('/project/3027010.01/middata/stats/allchan_phase_full_delta.mat','stat','-v7.3');

%% plot t-val figure
%colormap(jet)
colormap(turbo)
imagesc(stat.time, stat.time, squeeze(stat.stat));
%imagesc(stat.time, stat.time, squeeze(stat.stat));
hold on
contour(stat.time, stat.time, squeeze(stat.posclusterslabelmat == 1),1,'color',[1 1 1],'linewidth',4);
%contour(stat.time, stat.time, squeeze(stat.negclusterslabelmat == 1),1,'color',[1 1 1],'linewidth',2);
set(gca,'ydir','normal')
colorbar
caxis([-3.5, 3.5]);
c = colorbar;
c.TickDirection = 'in';
%caxis([-0.005 0.005]);
c.YTick = linspace(-3,3,2);
%c.label = "Spearman's rho";
%title('delta (1-3Hz) phase similarities: referent-pronoun (temporal channels)')
%xlabel('after referent onset (s)')
%ylabel('after pronoun onset (s)')
%% calculate mean sim
m_s = mean(mat_same,4);

m_d = mean(mat_diff,4);

s = mean(m_s(squeeze(stat.posclusterslabelmat == 1)));
d = mean(m_d(squeeze(stat.posclusterslabelmat == 1)));
%% plot rho difference figure
m_s = mean(mat_same,4);
m_d = mean(mat_diff,4);
m_diff = mean(m_s,4) - mean(m_d,4);

%colormap(jet)
colormap(turbo)
imagesc(stat.time, stat.time, m_diff);
%imagesc(stat.time, stat.time, squeeze(stat.stat));
hold on
%contour(stat.time, stat.time, squeeze(stat.posclusterslabelmat == 1),1,'color',[1 1 1],'linewidth',4);
contour(stat.time, stat.time, squeeze(stat.posclusterslabelmat == 1),1,'color',[0.7 .7 .7],'linewidth',4);
set(gca,'ydir','normal')
set(gcf,'position', [100 100 560 480])
colorbar
caxis([-0.005, 0.005]);
c = colorbar;
c.TickDirection = 'in';
%caxis([-0.005 0.005]);
c.YTick = linspace(-0.004, 0.004,2);
%c.label = "Spearman's rho";
%title('delta (1-3Hz) phase similarities: referent-pronoun (temporal channels)')
%xlabel('after referent onset (s)')
%ylabel('after referent onset (s)')

%% plot for same/diff
m_s = mean(mat_same,4);
m_d = mean(mat_diff,4);
m_diff = mean(m_s,4) - mean(m_d,4);
tiledlayout(1,3)

nexttile
imagesc(stat.time, stat.time, m_s);
set(gca,'ydir','normal')
colorbar
caxis([0.3 0.32]);
xlabel('after referent onset (s)')
ylabel('after pronoun onset (s)')
title('Matching')

nexttile
imagesc(stat.time, stat.time, m_d);
hold on
set(gca,'ydir','normal')
c = colorbar;
%c.Label.String = "Spearman's rho";
%c.Label.FontSize = 9;
%c.Label.FontWeight = 'bold';
c.TickDirection = 'in';
c.YTick = linspace(0.3,0.32,2);
%c.TickLabels = num2cell(0.30:0.32);
caxis([0.3 0.32]);
title('Nonmatching');
%xlabel('after referent onset (s)')
%ylabel('after pronoun onset (s)')

nexttile
imagesc(stat.time, stat.time, m_diff);
hold on
contour(stat.time, stat.time, squeeze(stat.posclusterslabelmat == 1),1,'color',[1 1 1],'linewidth',3);
set(gca,'ydir','normal')
c = colorbar;
c.TickDirection = 'in';
caxis([-0.005 0.005]);
c.YTick = linspace(-0.005,0.005,2);

title('Matching - Nonmatching')
xlabel('after referent onset (s)')
ylabel('after pronoun onset (s)')