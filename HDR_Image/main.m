function main(src)
    figure('name',src);
    result = HDR_Image(src, 2.5, 0.94, 5, 0.5, 2.0, 0.7, 0.02);
    subplot(2, 2, 3);
    imshow(result);
  %  imwrite(result, src);
    title('result');
end