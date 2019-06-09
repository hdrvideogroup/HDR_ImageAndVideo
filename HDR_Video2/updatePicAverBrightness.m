function newBrightness = updatePicAverBrightness(picPath, currentAverBrightness, last5AverBrightness)
    origin_img = imread(picPath);
    double_origin_img = im2double(origin_img);
    origin_hsv = rgb2hsv(double_origin_img);
    v_channel = origin_hsv(:, :, 3);
%% 判断如何调整
    if currentAverBrightness < last5AverBrightness
        brightAdjust = last5AverBrightness * 0.98 - currentAverBrightness;
    else
        brightAdjust = last5AverBrightness * 1.02 - currentAverBrightness;
    end
%% 调整图片亮度值
    v_channel = v_channel + brightAdjust;
    newBrightness = currentAverBrightness + brightAdjust;
    origin_hsv(:, :, 3) = v_channel;
%% 写回图片
    imwrite(hsv2rgb(origin_hsv), picPath);
end