function result = HDR_Image(img_src, Lmax, threshold_val, kernal_size, sigma, belta, gamma, delta)
    % 读取图片
    origin_img = imread(img_src);
%     imtool(origin_img);
    % subplot(2, 2, 1);
    % imshow(origin_img);
    % title('origin image');
    % 转化为double类型
    double_origin_img = im2double(origin_img);
    origin_hsv = rgb2hsv(double_origin_img);
    % 提取亮度通道
    %  subplot(2, 2, 2);
    v_channel = origin_hsv(:, :, 3);
    
    %%-----添加预处理去噪----------------
    tmp = v_channel;
    [m, n] = size(v_channel);
    for i = 1 : m - 3 + 1
        for j = 1 : n - 3 + 1
            list = v_channel(i : (i + 3 - 1), j : (j + 3 - 1));
            list = list(:);
            tmp(i + (3 - 1)/2, j + (3 - 1)/2) = median(list);
        end
    end
    v_channel = tmp;
    % imhist(v_channel);
%     title('origin histogram');
    % 逆色调映射
    inverse_v = inverse_mapping(v_channel, Lmax);
    % 阈值处理
    high_region = threshold(v_channel, threshold_val, kernal_size);
    L = merge(inverse_v, high_region, v_channel, sigma, belta, gamma, delta);
   %  subplot(2, 2, 4);
    % imhist(L);
    % title('result histogram');
    origin_hsv(:, :, 3) = L;
    result = hsv2rgb(origin_hsv);
end