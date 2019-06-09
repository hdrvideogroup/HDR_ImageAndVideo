## HDR图像部分

本次项目的HDR图像生成是基于单幅图像，利用HVS颜色空间模型进行高动态范围图像的生成。在该种方法中，主要运用三个部分[1]：

- 对图像亮度分量的反色调映射
- 对亮度分量求取阈值图像并进行高斯滤波保留高光部分细节
- 将前两部分处理得到的图像与色度分量图融合处理，在融合的同时对图像进行最后的色调调整和对比度优化。

![1560051550033](img1.png)

### 预处理：中值滤波

使用中值滤波可以避免椒盐噪声的影响。椒盐噪声是图像传感器、传输信道、解码处理等环节产生的黑白相间的噪声。利用中值滤波器进行亮度通道的处理，即对应像素点亮度值等于其8领域内（包括其本身）亮度值的中值，可以在较少信息损失的情况下进行噪声处理。

在matlab进行如下代码实现：
```matlab
 %%-----添加预处理去噪----------------
    tmp = v_channel;
    [m, n] = size(v_channel);
    for i = 1 : m - 3 + 1
        for j = 1 : n - 3 + 1
            list = v_channel(i : (i + 3 - 1), j : (j + 3 - 1));
            list = list(:);
            tmp(i + (3 - 1)/2, j + (3 - 1)/2) = median(list);
        end
    end
    v_channel = tmp;
```


### 将图像的RGB颜色空间转换到HSV颜色空间

在人眼的视网膜中，有大量的锥状细胞和杆状细胞，其中锥状细胞对亮光明暗而对于暗光不敏感，同时对颜色信息敏感且分辨率较高；而杆状细胞对暗光明暗却对颜色信息不敏感。所以使用HSV（也可以称作HVS）颜色空间，其包括色相、饱和度和亮度通道，模拟了人眼对于外界颜色、光线的感知方式，可以通过如下公式将图像的RGB空间和HSV空间互相转换：

RGB转HSV：
$$
R' = \frac{R}{225} \\
G' = \frac{G}{225} \\
B' = \frac{B}{225} \\
C_{max} = max(R', G', B')\\
C_{min} = min(R', G', B')\\
\delta = C_{max} - C_{min}\\
H =
\begin{cases}
0, & \delta = 0 \\
60° × (\frac{G'-B'}{\delta} + 0), & C_{max} = R' \\
60° × (\frac{B'-R'}{\delta} + 2), & C_{max} = G' \\
60° × (\frac{R'-G'}{\delta} + 4), & C_{max} = B' \\
\end{cases} \\
S =
\begin{cases}
0, & C_{max} = 0 \\
\frac{\delta}{C_{max}}, & C_{max} \neq0 \ \\
\end{cases}\\
V = C_{max}
$$


HSV转RGB：
$$
条件：0\leq H < 360, \qquad  0\leq S \leq 1  \qquad and \qquad  0 \leq V \leq 1 \\
C = V×S\\
X= C ×(1 - |\frac{H}{60°}mod\,2 - 1|)\\
m = V -C\\
(R', G', B) =
\begin{cases}
(C,X,0), & 0°\leq H < 60° \\
(X,C,0), & 60° \leq H < 120° \\
(0,C,X), & 120° \leq H < 180° \\
(0,X,C), & 180° \leq H < 240° \\
(X,0,C), & 240° \leq H < 300\\
(C,0,X), & 300° \leq H < 360°\\
\end{cases} \\
(R,G,B) = ((R' + m)×255,(G' + m)×255,(B' + m)×255 )
$$
在matlab中，可以使用其工具箱进行颜色空间的转换。

RGB转HSV：

```matlab
% 转化为double类型
    double_origin_img = im2double(origin_img);
    origin_hsv = rgb2hsv(double_origin_img);
```



HSV转RGB：

`result = hsv2rgb(origin_hsv);`

### 亮度分量的反色调处理

我们将HDR图像数据映射到LDR图像成为色调映射，而将LDR图像映射到HDR图像的过程成为反色调映射。通过如下反色调映射算子可以得到反色调映射的结果：
$$
L_w(x, y) = \frac{1}{2}L_{max} \cdot L_{white}((L_d(x, y) - 1) + \sqrt((1 - L_d(x, y))^2 + \frac{4L_d(x, y)}{L_{white}^2}))
$$
其中`Lmax`为LDR图像像素亮度最大值映射到HDR图像中值的大小，而`Lwhite`一般被赋值为`Lmax`，对于`Ld(x, y)`为LDR图像对应位置的亮度值，`Lw(x,y)`为HDR图像对应位置的亮度值。在项目中，我们将L_max取值为2.5，也就是说，其亮度值为LDR图像最大亮度值的2.5倍。





在Matlab中，我们通过如下代码实现：

```matlab
function transform_v = inverse_mapping(norm_v, Lmax)
    [m,n] = size(norm_v);
    transform_v = norm_v;
        for i = 1: m
            for j = 1 : n
                transform_v(i, j) = 0.5 * Lmax^2 * ((norm_v(i, j) - 1) + sqrt((1 - norm_v(i, j))^2 + 4 * norm_v(i, j) / Lmax^2));
            end
        end
%     imtool(transform_v);
    % 最后将v通道归一化，因为范围为[0, 1]
    %      transform_v = normalize(transform_v, 0.0, 1.0);
end
```

只需要将原LDR图像进行遍历即可。

### 高光区域处理

因为LDR图像中高光区域可能出现细节丢失、噪声增加的情况，所以需要对丢失的信息进行你不，这里通过单阈值处理、高通滤波器以及高斯滤波器进行高光区域的处理。主要有三个步骤：

- 单阈值处理
- 腐蚀操作
- 高斯滤波

#### 单阈值处理

对于设定的阈值e，如果亮度通道对应位置的值大于e则保留，小于e则取0。在项目中我们将e取为0.94。
$$
M(p) =
\begin{cases}
I_{dmax}, & I(p) > \varepsilon \\
0, & others \\
\end{cases} \\
$$


```matlab
 % 进行阈值处理    
    max_light = max(max(norm_v));
    e = threshold_val * max_light;
    [m,n] = size(norm_v);
    Mp = norm_v;
    for i = 1: m
        for j = 1 : n
            if norm_v(i, j) < e
                Mp(i ,j) = 0.0;
            end
        end
    end
```

#### 腐蚀操作

为了避免高光区域像素点亮度值对于周围低亮度值像素点的影响，我们需要进行腐蚀操作。在论文中，使用如下方法进行处理：
$$
E(x, y) = min_{(x',y'):e(x',y')\neq0}m(x+x',y+y')
$$
与论文不同的是在项目中，我们则是对图像进行遍历，如果某个像素点的亮度值非零，但其8领域内有零值，则将其亮度值设为0。

利用matlab进行代码实现：

```matlab
% 去除单个点进行腐蚀
    for i = 1: m
        for j = 1 : n
            if tmp(i, j) == 0
                continue;
            end
            isZero = 0;
            for a = i - 1 : i + 1
                for b = j - 1 : j + 1
                    if a < 1 || b < 1 || a > m || b > n
                        continue;
                    end
                    if Mp(a, b) == 0
                        isZero = 1;
                        break;
                    end
                end
                if isZero == 1
                    tmp(i, j) = 0;
                    break;
                end
            end
        end
    end
    Mp = tmp;
```

#### 高斯滤波

可以利用5×5核的高斯滤波进行卷积，以产生模糊的效果，能够有效模拟光线的衰减情况和去除部分噪声。

二维高斯滤波函数
$$
G(x,y) = Ae^{\frac{-(x-u_x)^2}{2 \sigma_x^2} + \frac{-(y-u_y)^2}{2 \sigma_y^2}}
$$
在Matlab我们直接运用工具箱中的函数进行高斯卷积即可。

`w = fspecial('gaussian',[kernal_size,kernal_size],1);`

### 融合处理

#### 低亮度区域的处理

因为较暗部分不能较好保持其亮度，可能会出现一些噪声，所以需要对暗部区域进行处理。
$$
L(x,y) = \sigma L_w(x,y),\qquad L_w(x,y) < \beta I_{min}
$$
其中的`sigma`我们使用了0.5，而`beta`我们使用了2.0。

对于高光区域的融合，我们进行如下处理：
$$
L(x,y) = \gamma L_w(x,y) + \delta L_h(x,y), \qquad x\geq 0
$$
其中的`gamma`我们选择0.7，而`delta`我们选择0.02。

最终，还需要将HSV颜色空间的图像转换到RGB颜色空间中。



### 实验结果

![1560059713672](C:\Users\chensh236\AppData\Roaming\Typora\typora-user-images\1560059713672.png)

可以看出，通过单张图像的HDR图像生成，可以获得比较高的亮度范围以及对比度范围。

我们将其渲染为样例视频，并转成VR可播放的形式，可以发现，在VR情景下，HDR图像的效果是比较明显的。



####　参考文献

[1]朱恩弘，张红英，吴亚东，霍永青　单幅图像的高动态范围图像生成方法[J]. 计算机辅助设计与图形学学报

[2]维基百科 HSL和HSV色彩空间 [I]. 