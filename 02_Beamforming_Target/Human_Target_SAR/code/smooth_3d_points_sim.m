function smoothed_points_sim = smooth_3d_points_once(points, r_current)
    % points: [X, Y, Z] 형태의 포인트 클라우드 데이터 (N x 3 배열)
    % r_current: 현재 반경 값

    % 새 포인트들을 저장할 배열 초기화
    smoothed_points_sim = [];
    
    % 방문한 포인트를 추적하기 위한 배열
    visited = false(size(points, 1), 1); 
    i = 1; % 인덱스 초기화
    
    % while 문 사용하여 현재 배열 크기 기준으로 반복
    while i <= size(points, 1)
        if visited(i)
            i = i + 1; % 이미 평균화된 포인트는 스킵
            continue;
        end
        
        % 중심 포인트 (x0, y0, z0)
        center_point = points(i, :);
        
        % 각 포인트와 중심점 사이의 거리 계산
        distances = sqrt(sum((points - center_point).^2, 2));
        
        % 반경 내에 있는 포인트들 추출
        neighbors_idx = find(distances <= r_current);
        neighbors = points(neighbors_idx, :);
        
        % 평균 계산 (X, Y, Z 각각)
        average_point = mean(neighbors, 1);
        
        % 새 포인트 리스트에 평균값 추가
        smoothed_points_sim = [smoothed_points_sim; average_point];
        
        % 평균화된 포인트들은 모두 처리된 것으로 표시
        visited(neighbors_idx) = true;
        
        % 다음 인덱스로 이동
        i = i + 1;
    end
end

