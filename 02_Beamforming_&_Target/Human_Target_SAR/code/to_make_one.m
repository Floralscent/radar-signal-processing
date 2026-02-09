clear all;
close all;

% 데이터가 저장된 폴더 설정
matfolder = './data_HJ/data';   % 실제 데이터 폴더 경로로 수정하세요.

% 컬러맵 설정
cmp = parula;          % 기본 MATLAB 컬러맵인 Parula 사용
cmp = flipud(cmp);     % 컬러맵을 상하 반전
colormap(cmp);         % 반전된 컬러맵을 적용
% 
% % 결과를 저장할 폴더 경로 설정
% sv_path = './new/';    % 결과를 저장할 폴더 경로로 수정하세요.

% 데이터 처리할 파일 목록 가져오기
D = dir(fullfile(matfolder, '*.mat'));   % 지정된 폴더에서 .mat 파일 목록 가져오기

% 포인트 클라우드의 속도 변화 설정(l-> +(왼오)/ r->-(오왼))
data_velo = 5 ; %% -20에
% 각 파일에 대해 처리 시작
file_idx=2; %% 20 번째
filename = D(file_idx).name;                        % 파일 이름 가져오기
load(fullfile(matfolder, filename));               % .mat 파일 로드
    % 포인트 클라우드의 각 스캔에 대해 처리
    point_cloud.alldata = [];  % 전체 데이터를 초기화
    point_cloud.flitdata = []; % 필터링된 데이터를 초기화

    for scan_idx = 1:point_cloud.scan
        % SR 데이터와 MR 데이터를 결합하여 mix_data 생성
        point_cloud.mix_cnt(scan_idx) = point_cloud.sr_cnt(scan_idx) + point_cloud.mr_cnt(scan_idx);
        point_cloud.mix_data{scan_idx} = [point_cloud.sr_data{scan_idx} point_cloud.mr_data{scan_idx}];
        
        % 데이터에 속도 변화 적용
        point_cloud.mix_data{scan_idx}(2,:) = point_cloud.mix_data{scan_idx}(2,:) + (data_velo * 1.03e-4 * scan_idx);
        
        % 도플러와 크기 데이터 추가
        point_cloud.mix_data{scan_idx}(4,:) = [point_cloud.sr_dop{scan_idx} point_cloud.mr_dop{scan_idx}];
        point_cloud.mix_data{scan_idx}(5,:) = [point_cloud.sr_mag{scan_idx} point_cloud.mr_mag{scan_idx}];

        % 필터링된 데이터를 저장할 공간 초기화
        point_cloud.filt_data{scan_idx} = point_cloud.mix_data{scan_idx};
        point_cloud.filt_cnt(scan_idx) = point_cloud.mix_cnt(scan_idx);

        % 데이터 필터링
        for pnt_idx = point_cloud.mix_cnt(scan_idx) : -1 : 1
            if point_cloud.filt_data{scan_idx}(5, pnt_idx) < 1e6 || point_cloud.filt_data{scan_idx}(1, pnt_idx) < 0.5
                point_cloud.filt_data{scan_idx}(:, pnt_idx) = [];  % 조건을 만족하지 않는 데이터 제거
                point_cloud.filt_cnt(scan_idx) = point_cloud.filt_cnt(scan_idx) - 1;
            end
        end

        % 첫 스캔 데이터라면 전체 데이터를 초기화, 그렇지 않다면 데이터 추가
        if scan_idx == 1
            point_cloud.alldata = point_cloud.mix_data{scan_idx};
            point_cloud.flitdata = point_cloud.filt_data{scan_idx};
        else
            point_cloud.alldata(:, end+1:end+point_cloud.mix_cnt(scan_idx)) = point_cloud.mix_data{scan_idx};
            point_cloud.flitdata(:, end+1:end+point_cloud.filt_cnt(scan_idx)) = point_cloud.filt_data{scan_idx};
        end

        % 시각화 (주석처리됨, 사용시 주석 해제)
        % x = point_cloud.mix_data{scan_idx}(1,:);
        % y = point_cloud.mix_data{scan_idx}(2,:);
        % z = point_cloud.mix_data{scan_idx}(3,:);
        % c = point_cloud.mix_data{scan_idx}(5,:);
        % ct = "Magnitute";
        % cl = [0 5e7];
        % 
        % x = point_cloud.flitdata(1,:);
        % y = point_cloud.flitdata(2,:);
        % z = point_cloud.flitdata(3,:);
        % c = point_cloud.flitdata(5,:);
        % ct = "Magnitute";
        % cl = [0 5e7];
        % Drow_3dsc(x,y,z,c,cl,ct)                % 3D 그래프를 그리는 사용자 정의 함수
        % saveas(gcf,fullfile(sv_path, sprintf('%02d_%d.png', file_idx, scan_idx))); % 그래프를 이미지로 저장
    end

    % 모든 스캔 데이터를 통합한 후 시각화 및 저장
    x = point_cloud.alldata(1,:);
    y = point_cloud.alldata(2,:);
    z = point_cloud.alldata(3,:);
    c = point_cloud.alldata(5,:);
    ct = "Magnitute";
    cl = [0 5e7];
    

    Drow_3dsc(x,y,z,c,cl,ct)                % 통합 데이터를 3D 그래프로 시각화
    % saveas(gcf, fullfile(sv_path, sprintf('%02d_all_data_3d_view.png', file_idx)));

    % 필터링된 데이터에 대해 시각화 및 저장
    x = point_cloud.flitdata(1,:);
    y = point_cloud.flitdata(2,:);
    z = point_cloud.flitdata(3,:);
    c = point_cloud.flitdata(5,:);
    ct = "Magnitute";
    cl = [0 5e7];


    Drow_3dsc(x,y,z,c,cl,ct)                % 통합 데이터를 3D 그래프로 시각화
    % saveas(gcf, fullfile(sv_path, sprintf('%02d_filtered_data_3d_view.png', file_idx)));

    
filtered_data_av=point_cloud.flitdata;
filtered_data_av=filtered_data_av';


% smrf
smrf_cluster1_points =  filtered_data_av(:, 1:3);

% smrf_cluster1_points를 pointCloud 객체로 변환
ptCloud = pointCloud(smrf_cluster1_points);

% 파라미터 설정
gridRes = 0.5;                % 격자 해상도
maxRadius = 18;                % 최대 반경 (조정 필요)
slopeThres = 0.15;            % 경사 임계값 (조정 필요)
elevThres = 0.1;             % 높이 임계값 (조정 필요)
% 함수 호출
[groundPtsIdx, nonGroundPtCloud, groundPtCloud] = segmentGroundSMRF(ptCloud, ...
    'MaxWindowRadius', maxRadius, ...
    'SlopeThreshold', slopeThres, ...
    'ElevationThreshold', elevThres, ...
    'GridResolution', gridRes);

% 결과 시각화
figure;

% 비지상 점군 시각화
scatter3(nonGroundPtCloud.Location(:,1), nonGroundPtCloud.Location(:,2), nonGroundPtCloud.Location(:,3), 5, 'b', 'filled'); % 초록색으로 표시
hold on;

% 지상 점군 시각화
scatter3(groundPtCloud.Location(:,1), groundPtCloud.Location(:,2), groundPtCloud.Location(:,3), 5, 'r', 'filled'); % 파란색으로 표시

% 제목 및 레이블 추가
title('Ground and Non-Ground Points');
xlabel('X-axis');
ylabel('Y-axis');
zlabel('Z-axis');
legend('Non-Ground Points', 'Ground Points');
grid on;
hold off;

% 결과 시각화 (비지상 점군만)
figure;

% 비지상 점군 시각화
scatter3(nonGroundPtCloud.Location(:,1), nonGroundPtCloud.Location(:,2), nonGroundPtCloud.Location(:,3), 10, 'b', 'filled'); % 초록색으로 표시

% 제목 및 레이블 추가
title('Non-Ground Points');
xlabel('X-axis');
ylabel('Y-axis');
zlabel('Z-axis');
legend('Non-Ground Points');
grid on;
hold off;


X = nonGroundPtCloud.Location(:, 1:3);


% minpts 설정
minpts = 6; % 최소 이웃 수

% 각 점에서 minpts번째로 가까운 거리 계산
kD = pdist2(X, X, 'euclidean', 'Smallest', minpts);

% K-거리 그래프의 데이터를 오름차순으로 정렬
sorted_kth_distances = sort(kD(end, :));

% % 1차 미분 계산 (각 점에서의 변화율)
% first_derivative = diff(sorted_kth_distances);
% 
% % 2차 미분 계산 (1차 미분의 변화율)
% second_derivative = diff(first_derivative);
% 
% % 2차 미분의 절대값이 최대가 되는 지점 찾기 (가장 큰 변화)
% [~, elbow_idx] = max(abs(first_derivative));
% 
% % epsilon 값은 해당 지점의 y 값
% epsilon = sorted_kth_distances(elbow_idx + 1);



epsilon=0.2;


% epsilon에 가장 가까운 점을 찾기 위해 절대 차이 계산
[~, elbow_idx] = min(abs(sorted_kth_distances - epsilon));

% DBSCAN 적용
labels = dbscan(X, epsilon, minpts);

% 결과 시각화 (3D DBSCAN 클러스터링 결과)
figure;
scatter3(X(:,1), X(:,2), X(:,3), 5, labels, 'filled');
title(['3D DBSCAN Clustering 결과 (epsilon = ' num2str(epsilon) ', minpts = ' num2str(minpts) ')']);
xlabel('X');
ylabel('Y');
zlabel('Z');
grid on;

% k-distance 그래프 시각화
figure;
plot(sorted_kth_distances, 'LineWidth', 1.5);
hold on;

% epsilon 값을 강조한 점 표시
plot(elbow_idx + 1, epsilon, 'ro', 'MarkerSize', 10); % epsilon 지점 표시
title('K-distance Graph with Epsilon (Using 2nd Derivative for Elbow Point)');
xlabel('Points sorted by distance to 6th nearest neighbor');
ylabel('Distance');
grid on;

disp(['Estimated epsilon value: ', num2str(epsilon)]);
hold off;

% 그래프를 이미지로 저장
% saveas(gcf, fullfile(sv_path, string(file_idx) + "_epsilon_graph.png"));


% 적절한 epsilon을 선택하여 DBSCAN 적용
% epsilon = 0.07; % K-거리 그래프를 참고하여 선택
minPts = 6;
idx = dbscan(filtered_data_av(:, 1:3), epsilon, minPts, 'Distance', 'euclidean');

% 클러스터 레이블 확인
unique_clusters = unique(idx);

% 유효한 클러스터의 개수 확인 (0은 노이즈로 간주)
num_clusters = numel(unique_clusters(unique_clusters > 0));

% 결과 출력
disp(['Detected number of clusters: ', num2str(num_clusters)]);

% 클러스터별로 점의 개수와 평균 벡터 크기, 벡터 크기의 총합 계산

% 클러스터의 고유한 레이블 추출
unique_clusters = unique(idx);

% 결과를 저장할 배열 초기화
num_clusters = length(unique_clusters);
cluster_stats = zeros(num_clusters, 5); % [클러스터 번호, 점의 개수, 평균 벡터 크기, 벡터 크기의 총합]

for i = 1:num_clusters
    % 클러스터 i에 속하는 점들 선택
    cluster_idx = idx == unique_clusters(i);
    cluster_points = filtered_data_av(cluster_idx, :);
    
    % 클러스터 내 점의 개수
    num_points = sum(cluster_idx);
    
    % 벡터 크기 계산 (5번째 열에서 추출)
    vector_magnitudes = cluster_points(:, 5);
    
    % 평균 벡터 크기와 총합 계산
    mean_mag = mean(vector_magnitudes);
    sum_mag = sum(vector_magnitudes);
    max_mag=max(vector_magnitudes);
    % 결과 저장
    cluster_stats(i, :) = [unique_clusters(i), num_points, mean_mag, sum_mag,max_mag];
end

% 각각을 내림차순으로 정렬
% 점의 개수(num_points)를 기준으로 내림차순 정렬
sorted_by_num_points = sortrows(cluster_stats, 2, 'descend');

% 평균 벡터 크기(mean_mag)를 기준으로 내림차순 정렬
sorted_by_mean_mag = sortrows(cluster_stats, 3, 'descend');

% 총합 벡터 크기(sum_mag)를 기준으로 내림차순 정렬
sorted_by_sum_mag = sortrows(cluster_stats, 4, 'descend');

% 최대 벡터 크기(max_mag)를 기준으로 내림차순 정렬
sorted_by_max_mag = sortrows(cluster_stats, 5, 'descend');
% DBSCAN 결과를 MAT 파일로 저장
save('dbscan_results.mat', 'idx', 'filtered_data_av', 'cluster_stats', 'sorted_by_num_points', 'sorted_by_mean_mag', 'sorted_by_sum_mag', 'sorted_by_max_mag');
% 
% % 시각화: 점의 개수 기준으로 정렬한 결과
% figure;
% bar(sorted_by_num_points(:, 1), sorted_by_num_points(:, 2), 'FaceColor', 'b');
% title('Clusters Sorted by Number of Points');
% xlabel('Cluster Number');
% ylabel('Number of Points');
% grid on;
% % saveas(gcf, fullfile(sv_path, 'sorted_by_num_points.png'));
% 
% % 시각화: 평균 벡터 크기 기준으로 정렬한 결과
% figure;
% bar(sorted_by_mean_mag(:, 1), sorted_by_mean_mag(:, 3), 'FaceColor', 'g');
% title('Clusters Sorted by Mean Vector Magnitude');
% xlabel('Cluster Number');
% ylabel('Mean Vector Magnitude');
% grid on;
% % saveas(gcf, fullfile(sv_path, 'sorted_by_mean_mag.png'));
% 
% % 시각화: 총합 벡터 크기 기준으로 정렬한 결과
% figure;
% bar(sorted_by_sum_mag(:, 1), sorted_by_sum_mag(:, 4), 'FaceColor', 'r');
% title('Clusters Sorted by Sum of Vector Magnitudes');
% xlabel('Cluster Number');
% ylabel('Sum of Vector Magnitudes');
% grid on;
% % saveas(gcf, fullfile(sv_path, 'sorted_by_sum_mag.png'));
% 
% % 시각화: 최대 벡터 크기 기준으로 정렬한 결과
% figure;
% bar(sorted_by_max_mag(:, 1), sorted_by_max_mag(:, 5), 'FaceColor', 'm');
% title('Clusters Sorted by Maximum Vector Magnitude');
% xlabel('Cluster Number');
% ylabel('Maximum Vector Magnitude');
% grid on;
% % saveas(gcf, fullfile(sv_path, 'sorted_by_max_mag.png'));
% 
% % 결과 시각화
% % 3D 데이터 클러스터링 결과 시각화
% figure;
% scatter3(filtered_data_av(:, 1), filtered_data_av(:, 2), filtered_data_av(:, 3), 5, idx, 'filled');
% title('DBSCAN Clustering - 3D View');
% xlabel('X');
% ylabel('Y');
% zlabel('Z');
% colorbar;
% grid on;
% 
% % 그래프를 이미지로 저장
% saveas(gcf, fullfile(sv_path, string(file_idx) + "_dbscan_3d_view.png"));

% % XY 평면 시각화
% figure;
% scatter(filtered_data_av(:, 1), filtered_data_av(:, 2), 15, idx, 'filled');
% title('DBSCAN Clustering - XY Plane');
% xlabel('X');
% ylabel('Y');
% colorbar;
% grid on;
% 
% % YZ 평면 시각화
% figure;
% scatter(filtered_data_av(:, 2), filtered_data_av(:, 3), 15, idx, 'filled');
% title('DBSCAN Clustering - YZ Plane');
% xlabel('Y');
% ylabel('Z');
% colorbar;
% grid on;
% 
% % ZX 평면 시각화
% figure;
% scatter(filtered_data_av(:, 1), filtered_data_av(:, 3), 15, idx, 'filled');
% title('DBSCAN Clustering - ZX Plane');
% xlabel('X');
% ylabel('Z');
% colorbar;
% grid on;

% cluster1에 속하는 점들만 선택
cluster1_points = filtered_data_av(idx == 1, :);

% cluster1 데이터를 mat 파일로 저장
% cluster1_filename = fullfile(sv_path, 'cluster1_points.mat'); % 저장할 파일 경로 설정
% save(cluster1_filename, 'cluster1_points'); % cluster1 데이터 저장
% 
% disp(['Cluster1 데이터를 ', cluster1_filename, '에 저장했습니다.']);

% 결과를 저장할 폴더 생성
output_folder = 'DBSCAN_cluster1_results';
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

% cluster1만을 포함한 데이터 시각화 (3D)
figure;
scatter3(cluster1_points(:, 1), cluster1_points(:, 2), cluster1_points(:, 3), 5, 'filled');
title('DBSCAN Clustering - Cluster 1 Only (3D View)');
xlabel('X');
ylabel('Y');
zlabel('Z');
grid on;
xlim([2 4]);
ylim([-0.5 1.5]);
zlim([0 2]);
% 3D 산점도를 이미지로 저장
saveas(gcf, fullfile(output_folder, 'DBSCAN_cluster1_3D_View.png'));

% XY 평면 시각화
figure;
scatter(cluster1_points(:, 1), cluster1_points(:, 2), 5, 'filled');
title('DBSCAN Clustering - Cluster 1 Only (XY Plane)');
xlabel('X');
ylabel('Y');
xlim([2 4]);
ylim([-0.5 1.5]);
grid on;
% XY 산점도를 이미지로 저장
saveas(gcf, fullfile(output_folder, 'DBSCAN_cluster1_XY_View.png'));

% YZ 평면 시각화
figure;
scatter(cluster1_points(:, 2), cluster1_points(:, 3), 5, 'filled');
title('DBSCAN Clustering - Cluster 1 Only (YZ Plane)');
xlabel('Y');
ylabel('Z');
xlim([-0.5 1.5]);
ylim([0 2]);
grid on;
% YZ 산점도를 이미지로 저장
saveas(gcf, fullfile(output_folder, 'DBSCAN_cluster1_YZ_View.png'));

% ZX 평면 시각화
figure;
scatter(cluster1_points(:, 1), cluster1_points(:, 3), 5, 'filled');
title('DBSCAN Clustering - Cluster 1 Only (ZX Plane)');
xlabel('X');
ylabel('Z');
xlim([2 4]);
ylim([0 2]);
grid on;
% XZ 산점도를 이미지로 저장
saveas(gcf, fullfile(output_folder, 'DBSCAN_cluster1_XZ_View.png'));



% 단층화 작업
cluster_points = cluster1_points(:, 1:3);
a = average_x_c_per_yz(cluster_points);

% 결과를 저장할 폴더 생성
output_folder = 'DBSCAN_cluster1_x_results';
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

% 3D 산점도 시각화 및 저장
figure;
scatter3(a(:, 1), a(:, 2), a(:, 3), 5, 'filled');
title('DBSCAN Clustering - Cluster 1 x 3D');
xlabel('X');
ylabel('Y');
zlabel('Z');
grid on;
xlim([2 4]);
ylim([-0.5 1.5]);
zlim([0 2]);
saveas(gcf, fullfile(output_folder, 'DBSCAN_cluster1_x_3D_View.png'));

% XZ 평면 시각화 및 저장
figure;
scatter(a(:, 1), a(:, 3), 5, 'filled'); % X와 Z 좌표 사용
title('DBSCAN Clustering - Cluster 1 x (XZ Plane)');
xlabel('X');
ylabel('Z');
xlim([2 4]);
zlim([0 2]);
grid on;
saveas(gcf, fullfile(output_folder, 'DBSCAN_cluster1_x_XZ_View.png'));

% XY 평면 시각화 및 저장
figure;
scatter(a(:, 1), a(:, 2), 5, 'filled');
title('DBSCAN Clustering - Cluster 1 x (XY Plane)');
xlabel('X');
ylabel('Y');
xlim([2 4]);
ylim([-0.5 1.5]);
grid on;
saveas(gcf, fullfile(output_folder, 'DBSCAN_cluster1_x_XY_View.png'));

% YZ 평면 시각화 및 저장
figure;
scatter(a(:, 2), a(:, 3), 5, 'filled');
title('DBSCAN Clustering - Cluster 1 x (YZ Plane)');
xlabel('Y');
ylabel('Z');
xlim([-0.5 1.5]);
ylim([0 2]);
grid on;
saveas(gcf, fullfile(output_folder, 'DBSCAN_cluster1_x_YZ_View.png'));


b=average_y_c_per_xz(cluster_points);


% 결과를 저장할 폴더 생성
output_folder = 'DBSCAN_cluster1_y_results';
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

% 3D 시각화
figure;
scatter3(b(:, 1), b(:, 2), b(:, 3), 5, 'filled');
title('DBSCAN Clustering - Cluster 1 y 3D');
xlabel('X');
ylabel('Y');
zlabel('Z');
grid on;
xlim([2 4]);
ylim([-0.5 1.5]);
zlim([0 2]);
% 3D 산점도를 이미지로 저장
saveas(gcf, fullfile(output_folder, 'DBSCAN_cluster1_y_3D_View.png'));

% XZ 평면 시각화
figure;
scatter(b(:, 1), b(:, 3), 5, 'filled'); % X와 Z 좌표 사용
title('DBSCAN Clustering - Cluster 1 y (XZ Plane)');
xlabel('X');
ylabel('Z');
xlim([2 4]);
zlim([0 2]);
grid on; % 그리드 추가
% XZ 산점도를 이미지로 저장
saveas(gcf, fullfile(output_folder, 'DBSCAN_cluster1_y_XZ_View.png'));

% XY 평면 시각화
figure;
scatter(b(:, 1), b(:, 2), 5, 'filled');
title('DBSCAN Clustering - Cluster 1 y (XY Plane)');
xlabel('X');
ylabel('Y');
xlim([2 4]);
ylim([-0.5 1.5]);
grid on;
% XY 산점도를 이미지로 저장
saveas(gcf, fullfile(output_folder, 'DBSCAN_cluster1_y_XY_View.png'));

% YZ 평면 시각화
figure;
scatter(b(:, 2), b(:, 3), 5, 'filled');
title('DBSCAN Clustering - Cluster 1 y (YZ Plane)');
xlabel('Y');
ylabel('Z');
xlim([-0.5 1.5]);
ylim([0 2]);
grid on;
% YZ 산점도를 이미지로 저장
saveas(gcf, fullfile(output_folder, 'DBSCAN_cluster1_y_YZ_View.png'));




c=average_z_c_per_xy(cluster_points);



% 결과를 저장할 폴더 생성
output_folder = 'DBSCAN_cluster1_z_results';
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

% 3D 시각화
figure;
scatter3(c(:, 1), c(:, 2), c(:, 3), 5, 'filled');
title('DBSCAN Clustering - Cluster 1 z 3D');
xlabel('X');
ylabel('Y');
zlabel('Z');
grid on;
xlim([2 4]);
ylim([-0.5 1.5]);
zlim([0 2]);
% 3D 산점도를 이미지로 저장
saveas(gcf, fullfile(output_folder, 'DBSCAN_cluster1_z_3D_View.png'));

% XZ 평면 시각화
figure;
scatter(c(:, 1), c(:, 3), 5, 'filled'); % X와 Z 좌표 사용
title('DBSCAN Clustering - Cluster 1 z (XZ Plane)');
xlabel('X');
ylabel('Z');
xlim([2 4]);
ylim([0 2]);
grid on; % 그리드 추가
% XZ 산점도를 이미지로 저장
saveas(gcf, fullfile(output_folder, 'DBSCAN_cluster1_z_XZ_View.png'));

% XY 평면 시각화
figure;
scatter(c(:, 1), c(:, 2), 5, 'filled');
title('DBSCAN Clustering - Cluster 1 z (XY Plane)');
xlabel('X');
ylabel('Y');
xlim([2 4]);
ylim([-0.5 1.5]);
grid on;
% XY 산점도를 이미지로 저장
saveas(gcf, fullfile(output_folder, 'DBSCAN_cluster1_z_XY_View.png'));

% YZ 평면 시각화
figure;
scatter(c(:, 2), c(:, 3), 5, 'filled');
title('DBSCAN Clustering - Cluster 1 z (YZ Plane)');
xlabel('Y');
ylabel('Z');
xlim([-0.5 1.5]);
ylim([0 2]);
grid on;
% YZ 산점도를 이미지로 저장
saveas(gcf, fullfile(output_folder, 'DBSCAN_cluster1_z_YZ_View.png'));


r_initial = 0.01;
r_decay = 0.9;
num_iterations = 10;

% 결과를 저장할 폴더 생성
output_folder = 'smoothed_points_results_0.01';
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end


% cluster1에 속하는 점들만 선택
cluster1_points = filtered_data_av(idx == 1, :);
cluster1_points=cluster1_points(:,1:3)
% 스무딩 과정
smoothed_points = cluster1_points; % 초기 포인트 데이터
for iter = 1:num_iterations
    % 현재 반경 계산
    r_current = r_initial * (r_decay ^ (iter - 1));
    
    % 한 번의 스무딩 처리
    smoothed_points = smooth_3d_points_sim(smoothed_points, r_current);
    
    % 시각화 및 저장
    figure;
    scatter3(smoothed_points(:, 1), smoothed_points(:, 2), smoothed_points(:, 3), 5, 'filled');
    title(['Iteration ', num2str(iter), ' - 3D View']);
    xlabel('X');
    ylabel('Y');
    zlabel('Z');
    grid on;
    % x, y, z 축의 범위 설정
    xlim([2 4]);
    ylim([-0.5 1.5]);
    zlim([0 2]);
    saveas(gcf, fullfile(output_folder, ['smoothed_points_3D_iter_', num2str(iter), '.png']));
    
    % XZ 평면
    figure;
    scatter(smoothed_points(:, 1), smoothed_points(:, 3), 5, 'filled');
    title(['Iteration ', num2str(iter), ' - XZ View']);
    xlabel('X');
    ylabel('Z');
    grid on;
    xlim([2 4]);
    zlim([0 2]);
    saveas(gcf, fullfile(output_folder, ['smoothed_points_XZ_iter_', num2str(iter), '.png']));
    
    % XY 평면
    figure;
    scatter(smoothed_points(:, 1), smoothed_points(:, 2), 5, 'filled');
    title(['Iteration ', num2str(iter), ' - XY View']);
    xlabel('X');
    ylabel('Y');
    xlim([2 4]);
    ylim([-0.5 1.5]);
    grid on;
    saveas(gcf, fullfile(output_folder, ['smoothed_points_XY_iter_', num2str(iter), '.png']));
    
    % YZ 평면
    figure;
    scatter(smoothed_points(:, 2), smoothed_points(:, 3), 5, 'filled');
    title(['Iteration ', num2str(iter), ' - YZ View']);
    xlabel('Y');
    ylabel('Z');
    xlim([-0.5 1.5]);
    ylim([0 2]);
    grid on;
    saveas(gcf, fullfile(output_folder, ['smoothed_points_YZ_iter_', num2str(iter), '.png']));
end

%%%%%%%%%%%%%%%%%

%% DBSCAN 결과에서 사람만 추출
cluster_label = 1; % 사람이 속한 DBSCAN 클러스터 번호 (예: 1번 클러스터)

% 사람만 포함된 포인트 선택
people_points = filtered_data_av(idx == cluster_label, :);

xl = [0 9];
yl = [-3 3];
zl = [0 3];
ct = "Magnitute";

% figure 생성
tiledlayout(2,2);% 3D 그래프 (첫 번째 subplot)
nexttile

% subplot(2, 2, 1); % 2x2 배열의 첫 번째 subplot
scatter3(people_points(:, 1), people_points(:, 2), people_points(:, 3), 5, people_points(:, 5), 'filled');
xlabel("Range[m]")
ylabel("Azimuth[m]")
zlabel("Elevation[m]")
xlim(xl)
ylim(yl)
zlim(zl)
clim(cl)


% XZ 평면 (세 번째 subplot)
nexttile

% subplot(2, 2, 2); % 2x2 배열의 세 번째 subplot
scatter(people_points(:, 1), people_points(:, 3), 5, people_points(:, 5), 'filled');
xticks([0 3 6 9])
xlabel("Range[m]")
ylabel("Elevation[m]")
xlim([0  9])
ylim(zl)
clim(cl)
grid on;

% YZ 평면 (네 번째 subplot)
nexttile

% subplot(2, 2, 3); % 2x2 배열의 네 번째 subplot
scatter(people_points(:, 2), people_points(:, 3), 10, people_points(:, 5), 'filled');
set(gca,'XDir','reverse');

xlabel("Azimuth[m]")
ylabel("Elevation[m]")
xlim([-3 3])

ylim([0 3])
clim(cl)
grid on;


% XY 평면 (두 번째 subplot)
nexttile

% subplot(2, 2, 4); % 2x2 배열의 두 번째 subplot
scatter(people_points(:, 1), people_points(:, 2), 5, people_points(:, 5), 'filled');
xticks([0 3 6 9])
xlabel("Range[m]")
ylabel("Azimuth[m]")
xlim(xl)
ylim([-3 3])
clim(cl)
grid on;

% % 그래프 레이아웃 조정
cb = colorbar;
cb.Layout.Tile = 'east';
cb.Label.String = ct;
colormap(flipud(parula));
% colormap(flipud(people_points(:, 5)));
% sgtitle('DBSCAN - People Only');
