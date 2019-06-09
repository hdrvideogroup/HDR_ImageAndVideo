clc;clear;

%%-------------- 多线程准备----------------------
mypar = parpool;
%------读取视频------------
fileName = 'test/test.mp4';
obj = VideoReader(fileName);
frames = obj.NumberOfFrames;
startFrame = 1;
if ~exist('./../Cache')
    mkdir('./../Cache'); 
end

if ~exist('./../Cache/originFrame')
    disp('提前生成所有帧');
    mkdir('./../Cache/originFrame');
    % 一次性生成所有的原图帧保存在Cache/originFrame/下，后续不用重复生成
     for k = 1 : frames
        frame = read(obj,k);
        imwrite(frame,strcat('./../Cache/originFrame',sprintf('%04d.bmp',k)),'bmp');
     end
end

 %--------------------------------
disp('begin to process iamges');
%% 可改进点：根据图片当前的亮度和最大最小亮度值来动态给出Lmax的值
% minB = min(averBrightness);
% maxB = max(averBrightness);
% maxL_max = 1.3;
% minL_max = 1.0;
% slope = (minL_max - maxL_max) / (maxB - minB);
%% 对视频的每一帧进行HDR 结果输出到origin文件夹下
 parfor k = startFrame : frames
     Lmax = 1.3
     result = main(['./../Cache/originFrame/', sprintf('%04d',k), '.bmp'], Lmax);
     imwrite(result,strcat('./../Cache/',sprintf('%04d.bmp',k)),'bmp');
     disp(['process No.',sprintf('%04d',k), ' image']);
 end

 %% 使用论文中的算法减轻闪烁
 disp('开始对结果帧进行亮度调整');
 flicker_removal(frames);

 %% 将结果写成视频
videoName = 'result.avi';
if(exist('videoName','file'))
    delete result.avi
end

obj=VideoWriter(videoName);

% 每秒30frames
obj.FrameRate = 30;  
disp('begin to write video');
open(obj);
for i = startFrame : frames
    fileName=sprintf('%04d',i);
    frames=imread(['./../Cache/',fileName,'.bmp']);
    writeVideo(obj,frames);
%      delete(['./../Cache/', fileName, '.bmp']);
end
close(obj);
% delete(mypar);
delete(gcp('nocreate'))
