function averaged_points = average_x_c_per_yz(points)
    % points: [X, Y, Z, C] 형태의 데이터 (N x 4 배열)
    
    % 소수점 3자리까지 반올림하여 Y와 Z 값 처리
    rounded_points = round(points(:, [2, 3]), 3); % Y와 Z만 반올림
    
    % (Y, Z) 쌍의 유일한 조합과 해당 인덱스 찾기
    [unique_coords, ~, ic] = unique(rounded_points, 'rows');
    
    % 각 (Y, Z) 쌍에 대한 X 값과 C 값 평균 계산
    grouped_x = accumarray(ic, points(:, 1), [], @mean);
    % grouped_c = accumarray(ic, points(:, 4), [], @mean);
    
    % (Y, Z, 평균 X, 평균 C) 형태로 결과 저장
    averaged_points = [ grouped_x,unique_coords];
end

