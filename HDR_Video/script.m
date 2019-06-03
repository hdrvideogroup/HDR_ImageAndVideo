clc;clear;

%%-------------- ���߳�׼��----------------------
mypar = parpool;
%------��ȡ��Ƶ------------
fileName = 'test/test.mp4';
obj = VideoReader(fileName);
frames = obj.NumberOfFrames;
startFrame = 1;
if ~exist('./../Cache')
    mkdir('./../Cache'); 
end

if ~exist('./../Cache/originFrame')
    disp('��ǰ��������֡');
    mkdir('./../Cache/originFrame');
    % һ�����������е�ԭͼ֡������Cache/originFrame/�£����������ظ�����
     for k = 1 : frames
        frame = read(obj,k);
        imwrite(frame,strcat('./../Cache/originFrame',sprintf('%04d.bmp',k)),'bmp');
     end
end

 %--------------------------------
disp('begin to process iamges');
%% �ɸĽ��㣺����ͼƬ��ǰ�����Ⱥ������С����ֵ����̬����Lmax��ֵ
% minB = min(averBrightness);
% maxB = max(averBrightness);
% maxL_max = 1.3;
% minL_max = 1.0;
% slope = (minL_max - maxL_max) / (maxB - minB);
%% ����Ƶ��ÿһ֡����HDR ��������origin�ļ�����
 parfor k = startFrame : frames
     Lmax = 1.3
     result = main(['./../Cache/originFrame/', sprintf('%04d',k), '.bmp'], Lmax);
     imwrite(result,strcat('./../Cache/',sprintf('%04d.bmp',k)),'bmp');
     disp(['process No.',sprintf('%04d',k), ' image']);
 end

 %% ʹ�������е��㷨������˸
 disp('��ʼ�Խ��֡�������ȵ���');
 flicker_removal(frames);

 %% �����д����Ƶ
videoName = 'result.avi';
if(exist('videoName','file'))
    delete result.avi
end

obj=VideoWriter(videoName);

% ÿ��30frames
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
