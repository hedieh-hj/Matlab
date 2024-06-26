%% hediye jamili %%

function harris_corner_detector()
    hFig = figure('Name', 'Harris Corner Detector', 'NumberTitle', 'off', ...
        'Position', [800, 100, 800, 500], 'ResizeFcn', @resizeFcn);

    % button to select an image
    uicontrol('Style', 'pushbutton', 'String', 'Select Image', ...
        'Units', 'normalized', 'Position', [0.05, 0.9, 0.2, 0.07], ...
        'Callback', @selectImage);

    % Axes
    Axes1 = axes('Parent', hFig, 'Units', 'normalized', ...
        'Position', [0.05, 0.05, 0.4, 0.8]);
    Axes2 = axes('Parent', hFig, 'Units', 'normalized', ...
        'Position', [0.55, 0.05, 0.4, 0.8]);

    function resizeFcn(~, ~)
        % No need to adjust axes positions explicitly, as they use normalized units
    end

    function selectImage(~, ~)        
        [file, path] = uigetfile({'*.jpg;*.jpeg;*.png;*.bmp', 'Image Files'}, 'Select an Image');
        if isequal(file, 0)
            disp('User selected Cancel');
        else
            fullFilePath = fullfile(path, file);
            disp(['User selected ', fullFilePath]);
            
            im2 = imread(fullFilePath);
            axes(Axes1);
            imshow(im2);
            title('Original Image');

            % Convert to grayscale if it's a color image
            if size(im2, 3) == 3
                I = rgb2gray(im2);
            else
                I = im2;
            end

            % Harris corner detection
            I_color = harrisCornerDetection(I, im2);

            axes(Axes2);
            imshow(I_color);
            title('Image with Harris Corner Detection');
        end
    end
end

function I_color = harrisCornerDetection(I, im2)
    k = 0.04;
    sigma = 2; % Use a larger sigma --> Gaussian kernel
    Threshold = 50000; 
    halfwid = sigma * 3;

    [xx, yy] = meshgrid(-halfwid:halfwid, -halfwid:halfwid);

    Gxy = exp(-(xx .^ 2 + yy .^ 2) / (2 * sigma ^ 2));
    Gx = xx .* exp(-(xx .^ 2 + yy .^ 2) / (2 * sigma ^ 2));
    Gy = yy .* exp(-(xx .^ 2 + yy .^ 2) / (2 * sigma ^ 2));

    numOfRows = size(I, 1);
    numOfColumns = size(I, 2);

    % 1) x and y derivatives of image
    Ix = conv2(I, Gx, 'same');
    Iy = conv2(I, Gy, 'same');

    % 2)  products of derivatives at every px
    Ix2 = Ix .^ 2;
    Iy2 = Iy .^ 2;
    Ixy = Ix .* Iy;

    % 3) Compute the sums of the products of derivatives at each px
    Sx2 = conv2(Ix2, Gxy, 'same');
    Sy2 = conv2(Iy2, Gxy, 'same');
    Sxy = conv2(Ixy, Gxy, 'same');

    im = zeros(numOfRows, numOfColumns);
    for x = 1:numOfRows
        for y = 1:numOfColumns
            % 4) Define at each px(x, y) matrix H
            H = [Sx2(x, y), Sxy(x, y); Sxy(x, y), Sy2(x, y)];

            % 5) response of the detector at each px
            R = det(H) - k * (trace(H) ^ 2);

            % 6) Threshold on value of R
            if (R > Threshold)
                im(x, y) = R;
            end
        end
    end

    % 7) Improved non-maximum suppression
    nonMaxSuppressed = nonmaxsuppression(im, 3);

    % Create a color version of the original image
    I_color = im2;

    % Mark corners on the original image with a green square
    mark_size = 1; % Size of the square mark
    for x = 1:numOfRows
        for y = 1:numOfColumns
            if nonMaxSuppressed(x, y)
                for dx = -mark_size:mark_size
                    for dy = -mark_size:mark_size
                        if (x+dx > 0) && (x+dx <= numOfRows) && (y+dy > 0) && (y+dy <= numOfColumns)
                            I_color(x+dx, y+dy, 1) = 0;   % Red channel
                            I_color(x+dx, y+dy, 2) = 255; % Green channel
                            I_color(x+dx, y+dy, 3) = 0;   % Blue channel
                        end
                    end
                end
            end
        end
    end
end

function suppressed = nonmaxsuppression(im, windowSize)
    % Perform non-maximum suppression --> to recognize more important corner
    suppressed = zeros(size(im));
    halfSize = floor(windowSize/2);
    
    for x = 1+halfSize:size(im, 1)-halfSize
        for y = 1+halfSize:size(im, 2)-halfSize
            window = im(x-halfSize:x+halfSize, y-halfSize:y+halfSize);
            if im(x, y) == max(window(:))
                suppressed(x, y) = im(x, y);
            end
        end
    end
end
