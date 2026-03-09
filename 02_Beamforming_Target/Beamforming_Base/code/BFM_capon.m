function [azi,ele,heat_map,max_mag]= BFM_capon(fft_data,steer_vec,ele_max,azi_max)
    max_mag = 0;
    heat_map = zeros(azi_max,ele_max);
    xt = (fft_data*fft_data'+ 1*diag(ones(1,192)) + 1j*diag(ones(1,192)));
    Rxt = inv(xt);
    for azi_idx = 1 : azi_max
        for ele_idx = 1 : ele_max             
            heat_map(azi_idx,ele_idx) = abs(1/(steer_vec(:,azi_idx,ele_idx)'* Rxt *steer_vec(:,azi_idx,ele_idx)));
            if heat_map(azi_idx,ele_idx) > max_mag
                azi = azi_idx;
                ele = ele_idx;
                max_mag = heat_map(azi_idx,ele_idx);
            end
        end
    end
end
