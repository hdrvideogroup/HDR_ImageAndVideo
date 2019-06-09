clc;clear;

%%-------------- ���߳�׼��----------------------
delete(gcp('nocreate'));
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
        imwrite(frame,strcat('./../Cache/originFrame/',sprintf('%04d.bmp',k)),'bmp');
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

%��ƽ������
averVideo = zeros(1, frames);
parfor k = startFrame : frames
    aver_bright = aver_brightness(['./../Cache/originFrame/', sprintf('%04d',k), '.bmp']);
    disp(['No. ', sprintf('%04d',k), 'averbrightness: ', sprintf('%f',aver_bright)]);
    averVideo(k) = aver_bright;
end
min_aver = min(averVideo);
disp(['Min aver: ', sprintf('%f',min_aver)]);
max_aver = max(averVideo);
disp(['Max aver: ', sprintf('%f',max_aver)]);

%% ����Ƶ��ÿһ֡����HDR ��������origin�ļ�����
 parfor k = startFrame : frames
     %��̬��Lmax
     %max_bright = max_brightness(['./../Cache/originFrame/', sprintf('%04d',k), '.bmp']);
     %aver_bright = aver_brightness(['./../Cache/originFrame/', sprintf('%04d',k), '.bmp']);
     %disp(['No. ', sprintf('%04d',k), 'averbrightness: ', sprintf('%f',aver_bright)]);
     %Lmax = 1.3 + (1.8 - 1.3) / (0.50 - 0.480) * (averVideo(k) - 0.480);
     Lmax = 1.3 + (1.6 - 1.3) / (max_aver - min_aver) * (averVideo(k) - min_aver);
     disp(['No. ', sprintf('%04d',k), 'lmax: ', sprintf('%f',Lmax)]);
     
     %Lmax = 1.8
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
