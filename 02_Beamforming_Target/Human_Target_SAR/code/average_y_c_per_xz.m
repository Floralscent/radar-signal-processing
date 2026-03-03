function averaged_points = average_y_c_per_xz(points)
    % points: [X, Y, Z, C] 형태의 데이터 (N x 4 배열)
    
    % 소수점 4자리까지 반올림하여 X와 Z 값 처리
    rounded_points = round(points(:, [1, 3]), 3); % X와 Z만 반올림
    
    % (X, Z) 쌍의 유일한 조합과 해당 인덱스 찾기
    [unique_coords, ~, ic] = unique(rounded_points, 'rows');
    
    % 각 (X, Z) 쌍에 대한 Y 값 평균 계산
    grouped_y = accumarray(ic, points(:, 2), [], @mean);
    
    % (X, 평균 Y, Z) 형태로 결과 저장
    averaged_points = [unique_coords(:, 1), grouped_y, unique_coords(:, 2)];
end

