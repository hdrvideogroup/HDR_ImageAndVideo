%% 返回图片的几何平均亮度值
function result = aver_geo_brightness(picPath)
    picPath = im2double(imread(picPath));
    deta = 0.001;
    picPath = log(picPath + deta);
    picPath = picPath(:);
    N = size(picPath, 1);
    result = exp(sum(picPath) / N);
end   