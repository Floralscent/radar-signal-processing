function [azi,ele,heat_map,max_mag,v]= BFM_music(fft_data,steer_vec,ele_max,azi_max)
    max_mag = 0;
    heat_map = zeros(azi_max,ele_max);
    xt = (fft_data*fft_data');
    [eigen_vec, eiv] = eig(xt);
    v=diag(eiv);
    Qn = (eigen_vec(:, 1:191));
    Qnn = Qn*Qn';
    for azi_idx = 1 : azi_max
        for ele_idx = 1 : ele_max             
            heat_map(azi_idx,ele_idx) = abs(1/(steer_vec(:,azi_idx,ele_idx)'*Qnn*steer_vec(:,azi_idx,ele_idx)));
            if heat_map(azi_idx,ele_idx) > max_mag
                azi = azi_idx;
                ele = ele_idx;
                max_mag = heat_map(azi_idx,ele_idx);
            end
        end
    end
end
