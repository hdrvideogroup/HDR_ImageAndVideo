function [] = flicker_removal(frameNum)
    inSameScene = false; %�Ƿ���ͬһ��������
    frame = 1;
    averBrightness = zeros(1, frameNum); % ���浱ǰ�õ�������֡ƽ������ֵ
    while frame <= frameNum
        if inSameScene
            averBrightness(frame) = aver_brightness(['./../Cache/', sprintf('%04d',frame), '.bmp']);
            last5AverBrightness = sum(averBrightness(:, frame-5: frame-1)) / 5; %����ǰ��֡��ƽ������ֵ
            brightDiff = abs(averBrightness(frame) - last5AverBrightness);
            if  brightDiff <= last5AverBrightness * 0.02 %ͬһ�����������������е���
                disp(['No.',sprintf('%04d',frame), ' image ͬһ�����������������е���']);             
                % do nothing
            elseif brightDiff >= last5AverBrightness * 0.1 %�����µĳ����������е���
                disp(['No.',sprintf('%04d',frame), ' image �����µĳ����������е���']);
                inSameScene = false; % ��ʶ�Ѿ������µĳ�����                 
            else %ͬһ����������˸����Ҫ��������ֵ
                disp(['No.',sprintf('%04d',frame), ' image ͬһ����������˸����Ҫ��������ֵ']);
                % ����ǰ5֡��������ֵ������ͼƬ�ͱ��������ֵ
                averBrightness(frame) = updatePicAverBrightness(['./../Cache/', sprintf('%04d',frame), '.bmp'], averBrightness(frame), last5AverBrightness);
            end
            frame = frame + 1;
        else
            for i = 0:4 % ���㲢�����³���ǰ��֡��ƽ������ֵ
                averBrightness(i + frame) = aver_brightness(['./../Cache/', sprintf('%04d',i + frame), '.bmp']);
            end
            inSameScene = true;
            frame = frame + 5;
        end
    end
end