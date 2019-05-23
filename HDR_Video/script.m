clc;clear;

%%-------------- 多线程准备----------------------
mypar = parpool;
%%------读取视频------------
fileName = 'test/test.mp4';
obj = VideoReader(fileName);
frames = obj.NumberOfFrames;
if ~exist('./../Cache')
     mkdir('./../Cache');
end
 for k = 1 : frames
     frame = read(obj,k);
     imwrite(frame,strcat('./../Cache/',sprintf('%04d.bmp',k)),'bmp');
 end
 %%--------------------------------
disp('begin to process iamges');
 parfor k = 1 : frames
     result = main(['./../Cache/', sprintf('%04d',k), '.bmp']);
     imwrite(result,strcat('./../Cache/',sprintf('%04d.bmp',k)),'bmp');
     disp(['process No.',sprintf('%04d',k), ' image']);
 end


videoName = 'result.avi';
if(exist('videoName','file'))
    delete result.avi
end

obj=VideoWriter(videoName);

% 每秒30frames
obj.FrameRate = 30;  
disp('begin to write video');
open(obj);
for i = 1 : frames
    fileName=sprintf('%04d',i);
    frames=imread(['./../Cache/',fileName,'.bmp']);
    writeVideo(obj,frames);
%      delete(['./../Cache/', fileName, '.bmp']);
end
close(obj);
% delete(mypar);
