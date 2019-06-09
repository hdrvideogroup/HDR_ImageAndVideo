function result = max_brightness(picPath)
    origin_img = imread(picPath);
    double_origin_img = im2double(origin_img);
    origin_hsv = rgb2hsv(double_origin_img);
    v_channel = origin_hsv(:, :, 3);
    v_channel = v_channel(:);
    
    result = max(v_channel);

end