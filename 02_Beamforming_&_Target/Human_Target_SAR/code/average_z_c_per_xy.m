function averaged_points = average_z_c_per_xy(points)
    % points: [X, Y, Z, C] 형태의 데이터 (N x 4 배열)
    
    % 소수점 4자리까지 반올림하여 X와 Y 값 처리
    rounded_points = round(points(:, [1, 2]), 3); % X와 Y만 반올림
    
    % (X, Y) 쌍의 유일한 조합과 해당 인덱스 찾기
    [unique_coords, ~, ic] = unique(rounded_points, 'rows');
    
    % 각 (X, Y) 쌍에 대한 Z 값 평균 계산
    grouped_z = accumarray(ic, points(:, 3), [], @mean);
    
    % (X, Y, 평균 Z) 형태로 결과 저장
    averaged_points = [unique_coords, grouped_z];
end

