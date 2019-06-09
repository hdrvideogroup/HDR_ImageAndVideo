function newBrightness = updatePicAverBrightness(picPath, currentAverBrightness, last5AverBrightness)
    origin_img = imread(picPath);
    double_origin_img = im2double(origin_img);
    origin_hsv = rgb2hsv(double_origin_img);
    v_channel = origin_hsv(:, :, 3);
%% �ж���ε���
    if currentAverBrightness < last5AverBrightness
        brightAdjust = last5AverBrightness * 0.98 - currentAverBrightness;
    else
        brightAdjust = last5AverBrightness * 1.02 - currentAverBrightness;
    end
%% ����ͼƬ����ֵ
    v_channel = v_channel + brightAdjust;
    newBrightness = currentAverBrightness + brightAdjust;
    origin_hsv(:, :, 3) = v_channel;
%% д��ͼƬ
    imwrite(hsv2rgb(origin_hsv), picPath);
end