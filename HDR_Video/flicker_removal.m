function [] = flicker_removal(frameNum)
    inSameScene = false; %是否在同一个场景中
    frame = 1;
    averBrightness = zeros(1, frameNum); % 保存当前得到的所有帧平均亮度值
    while frame <= frameNum
        if inSameScene
            averBrightness(frame) = aver_brightness(['./../Cache/', sprintf('%04d',frame), '.bmp']);
            last5AverBrightness = sum(averBrightness(:, frame-5: frame-1)) / 5; %计算前五帧的平均亮度值
            brightDiff = abs(averBrightness(frame) - last5AverBrightness);
            if  brightDiff <= last5AverBrightness * 0.02 %同一场景满足条件不进行调整
                disp(['No.',sprintf('%04d',frame), ' image 同一场景满足条件不进行调整']);             
                % do nothing
            elseif brightDiff >= last5AverBrightness * 0.1 %进入新的场景，不进行调整
                disp(['No.',sprintf('%04d',frame), ' image 进入新的场景，不进行调整']);
                inSameScene = false; % 标识已经进入新的场景中                 
            else %同一场景发生闪烁，需要调整亮度值
                disp(['No.',sprintf('%04d',frame), ' image 同一场景发生闪烁，需要调整亮度值']);
                % 根据前5帧调整亮度值并更新图片和保存的亮度值
                averBrightness(frame) = updatePicAverBrightness(['./../Cache/', sprintf('%04d',frame), '.bmp'], averBrightness(frame), last5AverBrightness);
            end
            frame = frame + 1;
        else
            for i = 0:4 % 计算并保存新场景前五帧的平均亮度值
                averBrightness(i + frame) = aver_brightness(['./../Cache/', sprintf('%04d',i + frame), '.bmp']);
            end
            inSameScene = true;
            frame = frame + 5;
        end
    end
end