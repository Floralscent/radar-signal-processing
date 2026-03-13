%% 모션캡쳐 데이터 처리
clear all; 
close all; clc;

lengthxaxis = 75;
% 파일 경로 변수 정의
dataPath = '.\motion0711\take2\';

start=100;

idxFileM=1;
File_list = dir(fullfile(dataPath, '*.csv'));
file = File_list(idxFileM).name; 
motionData = csvread(fullfile(dataPath, file), start, 0); 
% Mwalk_s=401;
% Mwalk_e=621;
% hip velo-15 acc-12
% right foot velo-76 acc-73
% right reg velo-55 acc-52
% right upreg velo-34 acc-31 
% left foot velo-139 acc-136
% left reg velo-118 acc-115
% left upreg velo-97 acc-94

% z?? 왜?
spine.velo= smooth(motionData(:,204),10)';
posi_tmp= smooth(motionData(:,207),10)';
% spine.posi= posi_tmp + env_rangemap_smd(1) + abs(posi_tmp(1));
spine.posi= posi_tmp+1;
% right.footvelo= smooth(motionData(:,78),10)';
right.legvelo= smooth(motionData(:,57),10)';
right.legposi= smooth(motionData(:,60),10)';
right.footvelo= smooth(motionData(:,78),10)';
right.footposi= smooth(motionData(:,81),10)';
% right.armvelo= smooth(motionData(:,309),10)';
% right.armposi= smooth(motionData(:,312),10)';
% right.forearmvelo= smooth(motionData(:,330),10)';
% right.forearmposi= smooth(motionData(:,333),10)';
% right.handvelo= smooth(motionData(:,351),10)';
% right.handposi= smooth(motionData(:,354),10)';

left.legvelo= smooth(motionData(:,120),10)';
left.legposi= smooth(motionData(:,123),10)';
left.footvelo= smooth(motionData(:,141),10)';
left.footposi= smooth(motionData(:,144),10)';
% left.armvelo= smooth(motionData(:,792),10)';
% left.armposi= smooth(motionData(:,795),10)';
% left.forearmvelo= smooth(motionData(:,813),10)';
% left.forearmposi= smooth(motionData(:,816),10)';
% left.handvelo= smooth(motionData(:,834),10)';
% left.handposi= smooth(motionData(:,837),10)';

frame=100;
frame_interval=1/frame;

frm2time=0:frame_interval:frame_interval*size(motionData,1);
frm2time(end)=[];

% plot()


%% motion capture peak
f1 = figure;
set(f1, 'Position', [900 100 1030 250]);
hold on
% plot(frm2time,right.legvelo ,'r', 'Linewidth',1.2)
% plot(frm2time,left.legvelo ,'b', 'Linewidth',1.2)
% plot(frm2time,right.footvelo ,'r', 'Linewidth',1.2)
% plot(frm2time,left.footvelo ,'b', 'Linewidth',1.2)
plot(frm2time,spine.velo ,'k', 'Linewidth',2)
xlabel('Time(s)','FontSize',14);
ylabel('Velocity(m/s)','FontSize',14);
xlim([0 lengthxaxis]);
ylim([-2 2]);
grid on;
hold off;

% f2 = figure;
% set(f2, 'Position', [900 100 1200 300]);
% grid on;
% plot(frm2time, spine.posi,'k' ,'Linewidth',2)

% doppler map
% imagesc(scan2time, phase2velo, log_doppler_sum_org)
% axis xy
% set(gca,'FontSize',15,'LineWidth',1,'FontWeight','bold');
% xlabel('time');
% ylabel('velocity[m/s]') ;
% title('Doppler map');


% figure, 
% hold on
% plot(frm2time,right.footvelo ,'k', 'Linewidth',1.5)
% plot(frm2time,left.footvelo ,'k--', 'Linewidth',1.5)
% plot(frm2time,right.legvelo ,'k', 'Linewidth',1.5)
% plot(frm2time,left.legvelo ,'k--', 'Linewidth',1.5)
% plot(frm2time,spine.velo ,'k', 'Linewidth',1.5)
% % plot(frm2time(Mwalk_s:Mwalk_e),right.footvelo(Mwalk_s:Mwalk_e) ,'k', 'Linewidth',1.5)
% % plot(frm2time(Mwalk_s:Mwalk_e),left.footvelo(Mwalk_s:Mwalk_e) ,'k', 'Linewidth',1.5)
% % plot(frm2time(Mwalk_s:Mwalk_e),right.legvelo(Mwalk_s:Mwalk_e) ,'k', 'Linewidth',1.5)
% % plot(frm2time(Mwalk_s:Mwalk_e),left.legvelo(Mwalk_s:Mwalk_e) ,'k', 'Linewidth',1.5)
% % plot(frm2time(Mwalk_s:Mwalk_e),spine.velo(Mwalk_s:Mwalk_e) ,'k', 'Linewidth',1.5)
% set(gca,'FontSize',12,'LineWidth',1,'FontWeight','bold');
% yticks([-5 -4 -3 -2 -1 0 1 2 3 4 5])
% xlabel('time[s]');
% ylabel('velocity[m/s]');
% title('Spine');
% title('Leg');
% title('Foot');
% xlim([frm2time(Mwalk_s) frm2time(Mwalk_e)])
% xlim([2.5 7.7])
% ylim([-5 5])
% grid on
% hold off
% 
% 
% % spine (몸통)
% [Mpks_spine,Mlocs_spine]=findpeaks(abs(spine.velo(Mwalk_s:Mwalk_e)), MinPeakDistance=30, MinPeakHeight=0);
% % rigth leg
% [MRpks_leg,MRlocs_leg]=findpeaks(abs(right.legvelo(Mwalk_s:Mwalk_e)), MinPeakDistance=90, MinPeakHeight=1.5);
% % right foot
% [MRpks_foot,MRlocs_foot]=findpeaks(abs(right.footvelo(Mwalk_s:Mwalk_e)), MinPeakDistance=100, MinPeakHeight=2);
% % left leg
% [MLpks_leg,MLlocs_leg]=findpeaks(abs(left.legvelo(Mwalk_s:Mwalk_e)), MinPeakDistance=90, MinPeakHeight=1.5);
% % left foot
% [MLpks_foot,MLlocs_foot]=findpeaks(abs(left.footvelo(Mwalk_s:Mwalk_e)), MinPeakDistance=90, MinPeakHeight=2);
% 
% figure, hold on
% plot(frm2time(Mwalk_s:Mwalk_e),right.footvelo(Mwalk_s:Mwalk_e) ,'r', frm2time(Mwalk_s+MRlocs_foot-1), MRpks_foot,'bdiamond', 'Linewidth',1.2,'MarkerFaceColor','r')
% plot(frm2time(Mwalk_s:Mwalk_e),left.footvelo(Mwalk_s:Mwalk_e) ,'r', frm2time(Mwalk_s+MLlocs_foot-1), MLpks_foot,'bdiamond', 'Linewidth',1.2,'MarkerFaceColor','r')
% plot(frm2time(Mwalk_s:Mwalk_e),right.legvelo(Mwalk_s:Mwalk_e) ,'g', frm2time(Mwalk_s+MRlocs_leg-1), MRpks_leg,'bdiamond', 'Linewidth',1.2,'MarkerFaceColor','g')
% plot(frm2time(Mwalk_s:Mwalk_e),left.legvelo(Mwalk_s:Mwalk_e) ,'g', frm2time(Mwalk_s+MLlocs_leg-1), MLpks_leg,'bdiamond', 'Linewidth',1.2,'MarkerFaceColor','g')
% plot(frm2time(Mwalk_s:Mwalk_e),spine.velo(Mwalk_s:Mwalk_e) ,'k', frm2time(Mwalk_s+Mlocs_spine-1), Mpks_spine,'bdiamond', 'Linewidth',1.2,'MarkerFaceColor','k')
% set(gca,'FontSize',12,'LineWidth',1,'FontWeight','bold');
% yticks([-5 -4 -3 -2 -1 0 1 2 3 4 5])
% xlabel('time[s]');
% ylabel('velocity[m/s]');
% xlim([frm2time(Mwalk_s) frm2time(Mwalk_e)])
% ylim([-5 5])
% 
% figure, hold on
% plot(part_scan2time(locs_min), pks_min,'k--p', 'Linewidth',1.2,'MarkerSize',10,'MarkerEdgeColor','r')
% plot(part_scan2time(P_locs_min), P_pks_min,'k--o', 'Linewidt',1.2,'MarkerSize',10,'MarkerEdgeColor','b')
% plot(frm2time(Mwalk_s+Mlocs_spine-1), Mpks_spine,'k--*', 'Linewidth',1.5,'MarkerSize',10,'MarkerEdgeColor',[0.5 0 0.8])
% 
% 
% % spine step time / step length / speed
% spine.time = frm2time(Mwalk_s+Mlocs_spine-1);
% spine.speed = Mpks_spine;
% for i=1:length(Mpks_spine)-1
%     spine.steptime(i) = spine.time(i+1) - spine.time(i);
%     spine.steplength(i) = spine.posi(Mwalk_s+Mlocs_spine(i+1)-1) - spine.posi(Mwalk_s+Mlocs_spine(i)-1);
% end
% for i=1:length(Mpks_spine)-2
%     spine.strtime(i) = spine.time(i+2) - spine.time(i);
%     spine.strlength(i) = spine.posi(Mwalk_s+Mlocs_spine(i+2)-1) - spine.posi(Mwalk_s+Mlocs_spine(i)-1);
% end
% for i=1:length(Mpks_spine)-1
%     Mspinespd2(i) =  spine.steplength(i) / spine.steptime(i);
% end
% 
% % right stride time / stride length / speed 
% right.legtime = frm2time(Mwalk_s+MRlocs_leg-1);
% right.legspeed = mean(MRpks_leg);
% for i=1:length(MRpks_leg)-1
%     right.legstrtime(i) = right.legtime(i+1) - right.legtime(i);
%     right.legstrlength(i) = spine.posi(Mwalk_s+MRlocs_leg(i+1)-1) - spine.posi(Mwalk_s+MRlocs_leg(i)-1);
% end
% right.foottime = frm2time(Mwalk_s+MRlocs_foot-1);
% right.footspeed = mean(MRpks_foot);
% for i=1:length(MRpks_foot)-1
%     right.footstrtime(i) = right.foottime(i+1) - right.foottime(i);
%     right.footstrlength(i) = spine.posi(Mwalk_s+MRlocs_foot(i+1)-1) - spine.posi(Mwalk_s+MRlocs_foot(i)-1);
% end
% 
% % left stride time / stride length / speed 
% left.legtime = frm2time(Mwalk_s+MLlocs_leg-1);
% left.legspeed = mean(MLpks_leg);
% for i=1:length(MLpks_leg)-1
%     left.legstrtime(i) = left.legtime(i+1) - left.legtime(i);
%     left.legstrlength(i) = spine.posi(Mwalk_s+MLlocs_leg(i+1)-1) - spine.posi(Mwalk_s+MLlocs_leg(i)-1);
% end
% left.foottime = frm2time(Mwalk_s+MLlocs_foot-1);
% left.footspeed = mean(MLpks_foot);
% for i=1:length(MLpks_foot)-1
%     left.footstrtime(i) = left.foottime(i+1) - left.foottime(i);
%     left.footstrlength(i) = spine.posi(Mwalk_s+MLlocs_foot(i+1)-1) - spine.posi(Mwalk_s+MLlocs_foot(i)-1);
% end
% legspeed=[left.legspeed right.legspeed];
% footspeed=[left.footspeed right.footspeed];
% 
% 
% 
% 
% 
% 
% 
% % step time,step length, range/time - speed
% Mlegpks_locs = [MLlocs_leg,MRlocs_leg];
% Mlegpks_locs = sort(Mlegpks_locs);
% Mlegpks_posi = spine.posi(Mwalk_s+Mlegpks_locs);
% for i=1:length(Mlegpks_locs)-1
%     Mlegsteptime(i) = frm2time(Mwalk_s+Mlegpks_locs(i+1)-1) - frm2time(Mwalk_s+Mlegpks_locs(i)-1);
%     Mlegsteplength(i) = Mlegpks_posi(i+1) - Mlegpks_posi(i);
% end
% 
% Mfootpks_locs = [MLlocs_foot,MRlocs_foot];
% Mfootpks_locs = sort(Mfootpks_locs);
% Mfootpks_posi = spine.posi(Mwalk_s+Mfootpks_locs);
% for i=1:length(Mfootpks_locs)-1
%     Mfootsteptime(i) = frm2time(Mwalk_s+Mfootpks_locs(i+1)-1) - frm2time(Mwalk_s+Mfootpks_locs(i)-1);
%     Mfootsteplength(i) = Mfootpks_posi(i+1) - Mfootpks_posi(i);
% end
% 
% for i=1:length(Mlegpks_locs)-1
%     Mlegspd2(i) =  Mlegsteplength(i) / Mlegsteptime(i);
% end
% 
% for i=1:length(Mfootpks_locs)-1
%     Mfootspd2(i) =  Mfootsteplength(i) / Mfootsteptime(i);
% end
% 
% fprintf('spine speed : %.2f ,  steptime : %.2f \n',mean(spine.speed),mean(spine.steptime));
% fprintf('leg speed : %.2f ,  steptime : %.2f \n',mean(legspeed),mean(Mlegsteptime));
% fprintf('foot speed : %.2f ,  steptime : %.2f \n',mean(footspeed),mean(Mfootsteptime));
% 
% mean(Mlegsteplength)
% 
% 
% % clear Msteptime Msteplength
% fprintf('홀 leg steptime : %.2f ,  steplength : %.2f \n',mean(Mlegsteptime(1:2:end)),mean(Mlegsteplength(1:2:end)));
% fprintf('짝 leg steptime : %.2f ,  steplength : %.2f \n\n',mean(Mlegsteptime(2:2:end)),mean(Mlegsteplength(2:2:end)));
% fprintf('홀 foot steptime : %.2f ,  steplength : %.2f \n',mean(Mfootsteptime(1:2:end)),mean(Mfootsteplength(1:2:end)));
% fprintf('짝 foot steptime : %.2f ,  steplength : %.2f \n\n',mean(Mfootsteptime(2:2:end)),mean(Mfootsteplength(2:2:end)));
% fprintf('홀 leg speed2 : %.2f , 최고 speed2 : %.2f \n',mean(Mlegspd2(1:2:end)),max(abs(Mlegspd2(1:2:end))));
% fprintf('짝 leg speed2 : %.2f , 최고 speed2 : %.2f \n\n',mean(Mlegspd2(2:2:end)),max(abs(Mlegspd2(2:2:end))));
% fprintf('홀 foot speed2 : %.2f , 최고 speed2 : %.2f \n',mean(Mfootspd2(1:2:end)),max(abs(Mfootspd2(1:2:end))));
% fprintf('짝 foot speed2 : %.2f , 최고 speed2 : %.2f \n\n',mean(Mfootspd2(2:2:end)),max(abs(Mfootspd2(2:2:end))));
% 
% 
% fprintf('오른쪽 leg \nstrtime : %.2f ,  strlength : %.2f \n',mean(right.legstrtime),mean(right.legstrlength));
% fprintf('평균 속도 : %.2f , 최고 속도 : %.2f \n\n',right.legspeed,max(abs(MRpks_leg)));
% fprintf('왼쪽 leg \nstrtime : %.2f ,  strlength : %.2f \n',mean(left.legstrtime),mean(left.legstrlength));
% fprintf('평균 속도 : %.2f , 최고 속도 : %.2f \n\n',left.legspeed,max(abs(MLpks_leg)));
% 
% fprintf('왼쪽 foot \n strtime : %.2f , strlength : %.2f \n',mean(left.footstrtime),mean(left.footstrlength));
% fprintf('평균 속도 : %.2f , 최고 속도 : %.2f \n\n',left.footspeed,max(abs(MLpks_foot)));
% fprintf('오른쪽 foot \n strtime : %.2f ,  strlength : %.2f \n',mean(right.footstrtime),mean(right.footstrlength));
% fprintf('평균 속도 : %.2f , 최고 속도 : %.2f \n\n',right.footspeed,max(abs(MRpks_foot)));
% 
% fprintf('몸통 홀 \nsteptime : %.2f , steplength : %.2f \n',mean(spine.steptime(1:2:end)),mean(spine.steplength(1:2:end)));
% fprintf('strtime : %.2f , strlength : %.2f \n',mean(spine.strtime(1:2:end)),mean(spine.strlength(1:2:end)));
% fprintf('평균속도 : %.2f , 최고 속도 : %.2f \n',mean(spine.speed(1:2:end)),max(Mpks_spine(1:2:end)));
% fprintf('speed2 : %.2f , 최고 speed2 : %.2f \n\n',mean(Mspinespd2(1:2:end)),max(abs(Mspinespd2(1:2:end))));
% fprintf('몸통 짝 \nsteptime : %.2f , steplength : %.2f \n',mean(spine.steptime(2:2:end)),mean(spine.steplength(2:2:end)));
% fprintf('strtime : %.2f , strlength : %.2f \n',mean(spine.strtime(2:2:end)),mean(spine.strlength(2:2:end)));
% fprintf('평균속도 : %.2f , 최고 속도 : %.2f \n',mean(spine.speed(2:2:end)),max(Mpks_spine(2:2:end)));
% fprintf('speed2 : %.2f , 최고 speed2 : %.2f \n\n',mean(Mspinespd2(2:2:end)),max(abs(Mspinespd2(2:2:end))));
% 
% 
% 
% 
% %% 앞뒤 자르고 중간부분만
% 
% %레이더 엔벨롭 돌리고 할 것
% 
% 
% figure,hold on
% xlim([scan2time(walk_start) scan2time(walk_end)])
% xlabel("time [s]")
% ylabel("range [m]")
% plot(frm2time(Mwalk_s:Mwalk_e),spine.posi(Mwalk_s:Mwalk_e),'k')
% plot(scan2time(walk_start:walk_end),env_rangemap_smd,'r--','Linewidth',2)
% legend(["motioncapture" "radar"])
% 
% 
% figure,
% plot(scan2time(walk_start:walk_end), RCD_percenv_btm,'r','Linewidth',2)
% ylim([phase2velo(1) phase2velo(end)])
% % ylim([0 phase2velo(end)])
% % ylim([phase2velo(1) 0])
% xlim([scan2time(walk_start) scan2time(walk_end)])
% xlabel("time [s]")
% ylabel("velocity [m/s]")
% hold on
% hold off
% plot(frm2time(Mwalk_s:Mwalk_e),spine.velo(Mwalk_s:Mwalk_e),'k','Linewidth',1.2)
% plot(frm2time(Mwalk_s:Mwalk_e),right.legvelo(Mwalk_s:Mwalk_e),'b','Linewidth',1.2)
% plot(frm2time(Mwalk_s:Mwalk_e),right.footvelo(Mwalk_s:Mwalk_e),'b','Linewidth',1.2)
% plot(frm2time(Mwalk_s:Mwalk_e),left.legvelo(Mwalk_s:Mwalk_e),'g','Linewidth',1.2)
% plot(frm2time(Mwalk_s:Mwalk_e),left.footvelo(Mwalk_s:Mwalk_e),'g','Linewidth',1.2)
% legend(["radar" "motioncapture-spine"],'Location','best','FontSize',12)
% legend(["radar" "motioncapture-right leg" "motioncapture-right foot"],'Location','best','FontSize',12)
% legend(["radar" "motioncapture-left leg" "motioncapture-left foot"],'Location','best','FontSize',12)
% legend(["motioncapture-right leg" "motioncapture-right foot" "motioncapture-left leg" "motioncapture-left foot"],'Location','best','FontSize',12)
% legend(["radar" "motioncapture-spine" "motioncapture-right leg" "motioncapture-right foot" "motioncapture-left leg" "motioncapture-left foot"],'Location','best','FontSize',12)
% legend(["motioncapture-spine" "motioncapture-right leg" "motioncapture-right foot" "motioncapture-left leg" "motioncapture-left foot"],'Location','best','FontSize',12)
% legend(["radar" "motioncapture-right leg" "motioncapture-right foot" "motioncapture-left leg" "motioncapture-left foot"],'Location','best','FontSize',12)
% 
% legend(["radar" "motioncapture-right leg" "motioncapture-left leg"],'Location','best','FontSize',12)
% legend(["radar" "motioncapture-right foot" "motioncapture-left foot"],'Location','best','FontSize',12)
% legend(["motioncapture-right leg" "motioncapture-left leg"],'Location','best','FontSize',12)
% legend(["motioncapture-right foot" "motioncapture-left foot"],'Location','southeast','FontSize',12)
% legend(["right foot" "left foot" "radar-foot"],'Location','southeast','FontSize',12)
% legend(["right leg" "left leg" "radar-leg"],'Location','southeast','FontSize',12)
% legend(["spine" "radar-spine"],'Location','southeast','FontSize',12)
% legend(["motioncapture" "radar"],'Location','southeast','FontSize',12)
% 
% 
% 
% %% 1구간
% figure('Position',[100,100,1460,400]);
% subplot(1,3,1)
% plot(scan2time(walk_start:walk_end), env_11,'r','Linewidth',2)
% ylim([0 phase2velo(end)])
% xlim([scan2time(walk_start) scan2time(walk_end)])
% xlabel("time [s]")
% ylabel("velocity [m/s]")
% hold on 
% plot(frm2time(Mwalk_s:Mwalk_e),spine.velo(Mwalk_s:Mwalk_e),'k','Linewidth',1.2)
% legend(["radar" "motioncapture-spine"],'Location','best','FontSize',12)
% 
% subplot(1,3,2)
% plot(scan2time(walk_start:walk_end), env_11,'r','Linewidth',2)
% ylim([0 phase2velo(end)])
% xlim([scan2time(walk_start) scan2time(walk_end)])
% xlabel("time [s]")
% ylabel("velocity [m/s]")
% hold on 
% plot(frm2time(Mwalk_s:Mwalk_e),right.legvelo(Mwalk_s:Mwalk_e),'b','Linewidth',1.2)
% plot(frm2time(Mwalk_s:Mwalk_e),left.legvelo(Mwalk_s:Mwalk_e),'g','Linewidth',1.2)
% legend(["radar" "motioncapture-right leg" "motioncapture-left leg"],'Location','best','FontSize',12)
% 
% subplot(1,3,3)
% plot(scan2time(walk_start:walk_end), env_11,'r','Linewidth',2)
% ylim([0 phase2velo(end)])
% xlim([scan2time(walk_start) scan2time(walk_end)])
% xlabel("time [s]")
% ylabel("velocity [m/s]")
% hold on 
% plot(frm2time(Mwalk_s:Mwalk_e),right.footvelo(Mwalk_s:Mwalk_e),'b--','Linewidth',1.2)
% plot(frm2time(Mwalk_s:Mwalk_e),left.footvelo(Mwalk_s:Mwalk_e),'g--','Linewidth',1.2)
% legend(["radar" "motioncapture-right foot" "motioncapture-left foot"],'Location','best','FontSize',12)
% 
% %% 2구간
% figure('Position',[100,100,1460,400]);
% subplot(1,3,1)
% plot(scan2time(walk_start:walk_end), env_11,'r','Linewidth',2)
% ylim([phase2velo(1) 0])
% xlim([scan2time(walk_start) scan2time(walk_end)])
% xlabel("time [s]")
% ylabel("velocity [m/s]")
% hold on 
% plot(frm2time(Mwalk_s:Mwalk_e),spine.velo(Mwalk_s:Mwalk_e),'k','Linewidth',1.2)
% legend(["radar" "motioncapture-spine"],'Location','best','FontSize',12)
% 
% subplot(1,3,2)
% plot(scan2time(walk_start:walk_end), env_11,'r','Linewidth',2)
% ylim([phase2velo(1) 0])
% xlim([scan2time(walk_start) scan2time(walk_end)])
% xlabel("time [s]")
% ylabel("velocity [m/s]")
% hold on 
% plot(frm2time(Mwalk_s:Mwalk_e),right.legvelo(Mwalk_s:Mwalk_e),'b','Linewidth',1.2)
% plot(frm2time(Mwalk_s:Mwalk_e),left.legvelo(Mwalk_s:Mwalk_e),'g','Linewidth',1.2)
% legend(["radar" "motioncapture-right leg" "motioncapture-left leg"],'Location','best','FontSize',12)
% 
% subplot(1,3,3)
% plot(scan2time(walk_start:walk_end), env_11,'r','Linewidth',2)
% ylim([phase2velo(1) 0])
% xlim([scan2time(walk_start) scan2time(walk_end)])
% xlabel("time [s]")
% ylabel("velocity [m/s]")
% hold on 
% plot(frm2time(Mwalk_s:Mwalk_e),right.footvelo(Mwalk_s:Mwalk_e),'b--','Linewidth',1.2)
% plot(frm2time(Mwalk_s:Mwalk_e),left.footvelo(Mwalk_s:Mwalk_e),'g--','Linewidth',1.2)
% legend(["radar" "motioncapture-right foot" "motioncapture-left foot"],'Location','best','FontSize',12)













