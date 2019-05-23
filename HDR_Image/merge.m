function result = merge(inverse_v, high_region, v_channel, sigma, belta, gamma, delta)
    Imin = min(min(v_channel));
    result = inverse_v;
    [m,n] = size(v_channel);
    for i = 1: m
        for j = 1 : n
            if inverse_v(i, j) < belta * Imin
                result(i, j) = sigma * inverse_v(i, j);
            else
                result(i, j) = gamma * inverse_v(i, j) + delta * high_region(i, j);
            end
            if result(i, j) > 1.0
                result(i, j) = 1.0;
            end
            if result(i, j) < 0.0
                    result(i, j) = 0.0;
            end
        end
    end
end