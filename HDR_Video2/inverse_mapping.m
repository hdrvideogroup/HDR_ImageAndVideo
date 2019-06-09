function transform_v = inverse_mapping(norm_v, Lmax)
    [m,n] = size(norm_v);
    transform_v = norm_v;
        for i = 1: m
            for j = 1 : n
                transform_v(i, j) = 0.5 * Lmax^2 * ((norm_v(i, j) - 1) + sqrt((1 - norm_v(i, j))^2 + 4 * norm_v(i, j) / Lmax^2));
            end
        end
%     imtool(transform_v);
    % 最后将v通道归一化，因为范围为[0, 1]
    %      transform_v = normalize(transform_v, 0.0, 1.0);
end