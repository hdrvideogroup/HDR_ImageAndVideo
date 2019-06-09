%% 返回图片的亮度值
function result = aver_brightness(picPath)
    origin_img = imread(picPath);
    double_origin_img = im2double(origin_img);
    origin_hsv = rgb2hsv(double_origin_img);
    v_channel = origin_hsv(:, :, 3);
    v_channel = v_channel(:);
    %result = sum(v_channel) / size(v_channel, 1);
    
    m = sort(v_channel);
    m(find(m==max(m))) = [];
    m(find(m==min(m))) = [];
    m(find(m==max(m))) = [];
    m(find(m==min(m))) = [];
    result = mean(m);
end