function result = threshold(norm_v, threshold_val, kernal_size)
    % ������ֵ����    
    max_light = max(max(norm_v));
    e = threshold_val * max_light;
    [m,n] = size(norm_v);
    Mp = norm_v;
    for i = 1: m
        for j = 1 : n
            if norm_v(i, j) < e
                Mp(i ,j) = 0.0;
            end
        end
    end
%     imtool(Mp);
    % ���и�ʴ����
    tmp = Mp;
%     for i = 1: m
%         for j = 1 : n
%             if tmp(i, j) == 0
%                 continue;
%             end
%             min = 2.0;
%             for a = i - 2 : i + 2
%                 for b = j - 2 : j + 2
%                     if a < 1 || b < 1 || a > m || b > n || Mp(a, b) == 0
%                         continue;
%                     end
%                     if Mp(a, b) < min
%                         min = Mp(a, b);
%                     end
%                 end
%             end
%             tmp(i, j) = min;
%         end
%     end
    % ȥ����������и�ʴ
    for i = 1: m
        for j = 1 : n
            if tmp(i, j) == 0
                continue;
            end
            isZero = 0;
            for a = i - 1 : i + 1
                for b = j - 1 : j + 1
                    if a < 1 || b < 1 || a > m || b > n
                        continue;
                    end
                    if Mp(a, b) == 0
                        isZero = 1;
                        break;
                    end
                end
                if isZero == 1
                    tmp(i, j) = 0;
                    break;
                end
            end
        end
    end
    Mp = tmp;
%     imtool(Mp);
    w = fspecial('gaussian',[kernal_size,kernal_size],1);
	result = imfilter(Mp,w,'replicate');
%     imtool(result);
end