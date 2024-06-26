classdef GUI_image_processing < matlab.apps.AppBase

    % app components
    properties (Access = private)
        UIFigure          matlab.ui.Figure
        ImageAxes         matlab.ui.control.UIAxes
        SelectImageButton matlab.ui.control.Button
        GrayscaleButton   matlab.ui.control.Button
        BlurButton        matlab.ui.control.Button
        SharpenButton     matlab.ui.control.Button
        ContrastButton    matlab.ui.control.Button
        EdgeDetectionMenu matlab.ui.control.DropDown
        FeatureDetectionMenu matlab.ui.control.DropDown
        RotateButton      matlab.ui.control.Button
        MirrorButton      matlab.ui.control.Button
        ResetButton       matlab.ui.control.Button
        SaveButton        matlab.ui.control.Button
        OriginalImage     % Store original image data
        CurrentImage      % Store current modified image data
    end

    
    methods (Access = private)

        %% Select Image Button
        function selectImage(app, ~)
            [file, path] = uigetfile({'*.jpg;*.jpeg;*.png;*.bmp', 'Image Files'}, 'Select an Image');
            if isequal(file, 0)
                disp('User selected Cancel');
            else
                fullFilePath = fullfile(path, file);
                disp(['User selected ', fullFilePath]);
                app.loadImage(fullFilePath);
                app.updateButtonState('on'); % Enable relevant buttons after image selection
            end
        end

        %% Load image and display
        function loadImage(app, imagePath)
            app.OriginalImage = imread(imagePath);
            app.CurrentImage = app.OriginalImage;
            
            % Display image in UIAxes
            imshow(app.CurrentImage, 'Parent', app.ImageAxes);
        end

        %%  GrayscaleButton
        function convertToGrayscale(app, ~)
            if isempty(app.CurrentImage)
                return;
            end
            app.CurrentImage = rgb2gray(app.CurrentImage);
            app.updateDisplay();
        end

        %% BlurButton
        function blurImage(app, ~)
            if isempty(app.CurrentImage)
                return;
            end
            app.CurrentImage = imgaussfilt(app.CurrentImage, 2); % Gaussian blur with sigma = 2
            app.updateDisplay();
        end

        %% Sharpen Button
        function sharpenImage(app, ~)
            if isempty(app.CurrentImage)
                return;
            end
            app.CurrentImage = imsharpen(app.CurrentImage);
            app.updateDisplay();
        end

        %% Contrast Button
        function increaseContrast(app, ~)
            if isempty(app.CurrentImage)
                return;
            end
            app.CurrentImage = imadjust(app.CurrentImage, [], [], 2); % Increase contrast
            app.updateDisplay();
        end

        %% Edge Detection Menu
        function edgeDetection(app, event)
            if isempty(app.CurrentImage)               
                return;
            end
            
            % Check if image needs to be reset first
%             if ~isequal(app.CurrentImage, app.OriginalImage)
%                 choice = questdlg('Edge detection requires resetting the image. do you want Reset image and apply this action?', ...
%                     'Reset Image', 'Yes', 'Cancel', 'Cancel');
%                 if strcmp(choice, 'Yes')
%                     app.resetImage();
%                     app.DisabledButton('off');
%                 else
%                     return;
%                 end
%             end
            
            method = event.Value;
            switch method
                case 'Select a edge detection technique'
                case 'Sobel'
                    % Convert to grayscale if it's a color image
                    if size(app.CurrentImage, 3) == 3
                        app.CurrentImage = rgb2gray(app.CurrentImage);
                    else
                        app.CurrentImage = app.CurrentImage;
                    end

                    app.CurrentImage = edge(app.CurrentImage, 'Sobel');
                    app.DisabledButton('off');                    
                    app.EdgeDetectionMenu.Value = 'Select a edge detection technique';

                case 'Canny'
                    % Convert to grayscale if it's a color image
                    if size(app.CurrentImage, 3) == 3
                        app.CurrentImage = rgb2gray(app.CurrentImage);
                    else
                        app.CurrentImage = app.CurrentImage;
                    end

                    app.CurrentImage = edge(app.CurrentImage, 'Canny');
                    app.DisabledButton('off');  
                    app.EdgeDetectionMenu.Value = 'Select a edge detection technique';
            end
            app.updateDisplay();
        end

        %% Feature Detection Menu
        function featureDetection(app, event)
            if isempty(app.CurrentImage)                 
                return;
            end
            
            % Check if image needs to be reset first
%             if ~isequal(app.CurrentImage, app.OriginalImage)
%                 choice = questdlg('Feature detection requires resetting the image. do you want Reset image and apply this action?', ...
%                     'Reset Image', 'Yes', 'Cancel', 'Cancel');
%                 if strcmp(choice, 'Yes')                    
%                     app.resetImage();
%                     app.DisabledButton('off');
%                 else
%                     return;
%                 end
%             end
            
            method = event.Value;
            switch method
                case 'Select a feature detection technique'
                case 'Harris'
                     % Convert to grayscale if it's a color image
                    if size(app.CurrentImage, 3) == 3
                        app.CurrentImage = rgb2gray(app.CurrentImage);
                    else
                        app.CurrentImage = app.CurrentImage;
                    end
                    points = detectHarrisFeatures(app.CurrentImage);                                                           
                    app.CurrentImage = insertMarker(app.CurrentImage , points.Location, '+', 'Color', 'green');
                    app.DisabledButton('off');                    
                    app.FeatureDetectionMenu.Value = 'Select a feature detection technique';     
                case 'SIFT'
                    % Convert to grayscale if it's a color image
                    if size(app.CurrentImage, 3) == 3
                        app.CurrentImage = rgb2gray(app.CurrentImage);
                    else
                        app.CurrentImage = app.CurrentImage;
                    end
                    points = detectSIFTFeatures(app.CurrentImage);
                    app.CurrentImage = insertMarker(app.CurrentImage, points.Location, '+', 'Color', 'green');                   
                    app.DisabledButton('off');   
                    app.FeatureDetectionMenu.Value = 'Select a feature detection technique';     
            end
            app.updateDisplay();
        end

        %% Rotate Button
        function rotateImage(app, ~)
            if isempty(app.CurrentImage)
                return;
            end
            app.CurrentImage = imrotate(app.CurrentImage, 90); % Rotate image 90 degrees
            app.updateDisplay();
        end

        %% Mirror Button
        function mirrorImage(app, ~)
            if isempty(app.CurrentImage)
                return;
            end
            app.CurrentImage = flip(app.CurrentImage, 2); % Mirror horizontally
            app.updateDisplay();
        end

        %% Reset Button
        function resetImage(app, ~)
            if isempty(app.OriginalImage)
                app.CurrentImage = app.OriginalImage;
            end
            app.CurrentImage = app.OriginalImage;
            app.updateDisplay();
            app.updateButtonState('on'); % Enable all buttons      
        end

        %% SaveButton
        function saveImage(app, ~)
            if isempty(app.CurrentImage)
                return;
            end
            [file, path] = uiputfile({'*.jpg;*.jpeg;*.png;*.bmp', 'Image Files'}, 'Save Image');
            if isequal(file, 0)
                disp('User selected Cancel');
            else
                fullFilePath = fullfile(path, file);
                disp(['User selected ', fullFilePath]);
                imwrite(app.CurrentImage, fullFilePath);
                msgbox('Image saved successfully!', 'Success');
            end
        end

        %% Update display function
        function updateDisplay(app)
            cla(app.ImageAxes);
            imshow(app.CurrentImage, 'Parent', app.ImageAxes);
        end
        
        %% Update button states
        function updateButtonState(app, state)            
            app.GrayscaleButton.Enable = state;
            app.BlurButton.Enable = state;
            app.SharpenButton.Enable = state;
            app.ContrastButton.Enable = state;
            app.EdgeDetectionMenu.Enable = state;
            app.FeatureDetectionMenu.Enable = state;
            app.RotateButton.Enable = state;
            app.MirrorButton.Enable = state;
            app.ResetButton.Enable = state;
            app.SaveButton.Enable = state;
        end

        function DisabledButton(app, state)            
            app.GrayscaleButton.Enable = state;
            app.BlurButton.Enable = state;
            app.SharpenButton.Enable = state;
            app.ContrastButton.Enable = state; 
            app.EdgeDetectionMenu.Enable = state;
            app.FeatureDetectionMenu.Enable = state;
            app.ResetButton.Enable = 'on';           
        end

    end

    % App initialization and construction
    methods (Access = private)

        % Create UIFigure and components
        function createComponentss(app)
            %% UIFigure
            app.UIFigure = uifigure;
            app.UIFigure.Position = [100 100 900 600];
            app.UIFigure.Name = 'Image Processing App';

            %% ImageAxes
            app.ImageAxes = uiaxes(app.UIFigure);
            app.ImageAxes.Position = [50 50 600 500];

            %% buttons
            buttonX = 700;
            buttonY = 550;
            buttonSpacing = 50;
            buttonWidth = 120;
            buttonHeight = 22;

            app.SelectImageButton = uibutton(app.UIFigure, 'push');
            app.SelectImageButton.Text = 'Select Image';
            app.SelectImageButton.Position = [buttonX buttonY buttonWidth buttonHeight];
            app.SelectImageButton.ButtonPushedFcn = @(~,~) selectImage(app);

            app.GrayscaleButton = uibutton(app.UIFigure, 'push');
            app.GrayscaleButton.Text = 'Grayscale';
            app.GrayscaleButton.Position = [buttonX buttonY-buttonSpacing buttonWidth buttonHeight];            
            app.GrayscaleButton.Enable = 'off'; 
            app.GrayscaleButton.ButtonPushedFcn = @(~,~) convertToGrayscale(app);

            app.BlurButton = uibutton(app.UIFigure, 'push');
            app.BlurButton.Text = 'Blur Image';
            app.BlurButton.Position = [buttonX buttonY-2*buttonSpacing buttonWidth buttonHeight];
            app.BlurButton.Enable = 'off'; 
            app.BlurButton.ButtonPushedFcn = @(~,~) blurImage(app);

            app.SharpenButton = uibutton(app.UIFigure, 'push');
            app.SharpenButton.Text = 'Sharpen Image';
            app.SharpenButton.Position = [buttonX buttonY-3*buttonSpacing buttonWidth buttonHeight];
            app.SharpenButton.Enable = 'off'; 
            app.SharpenButton.ButtonPushedFcn = @(~,~) sharpenImage(app);

            app.ContrastButton = uibutton(app.UIFigure, 'push');
            app.ContrastButton.Text = 'Increase Contrast';
            app.ContrastButton.Position = [buttonX buttonY-4*buttonSpacing buttonWidth buttonHeight];
            app.ContrastButton.Enable = 'off'; 
            app.ContrastButton.ButtonPushedFcn = @(~,~) increaseContrast(app);

            app.EdgeDetectionMenu = uidropdown(app.UIFigure);
            app.EdgeDetectionMenu.Items = {'Select a edge detection technique','Sobel', 'Canny'};
                       app.EdgeDetectionMenu.Position = [buttonX buttonY-5*buttonSpacing buttonWidth buttonHeight];
            app.EdgeDetectionMenu.Enable = 'off';
            app.EdgeDetectionMenu.ValueChangedFcn = @(~,event) edgeDetection(app, event);

            app.FeatureDetectionMenu = uidropdown(app.UIFigure);
            app.FeatureDetectionMenu.Items = {'Select a feature detection technique','Harris', 'SIFT'};
            app.FeatureDetectionMenu.Position = [buttonX buttonY-6*buttonSpacing buttonWidth buttonHeight];
            app.FeatureDetectionMenu.Enable = 'off'; 
            app.FeatureDetectionMenu.ValueChangedFcn = @(~,event) featureDetection(app, event);

            app.RotateButton = uibutton(app.UIFigure, 'push');
            app.RotateButton.Text = 'Rotate 90°';
            app.RotateButton.Position = [buttonX buttonY-7*buttonSpacing buttonWidth buttonHeight];
            app.RotateButton.Enable = 'off'; 
            app.RotateButton.ButtonPushedFcn = @(~,~) rotateImage(app);

            app.MirrorButton = uibutton(app.UIFigure, 'push');
            app.MirrorButton.Text = 'Mirror Image';
            app.MirrorButton.Position = [buttonX buttonY-8*buttonSpacing buttonWidth buttonHeight];
            app.MirrorButton.Enable = 'off'; 
            app.MirrorButton.ButtonPushedFcn = @(~,~) mirrorImage(app);

            app.ResetButton = uibutton(app.UIFigure, 'push');
            app.ResetButton.Text = 'Reset Image';
            app.ResetButton.Position = [buttonX buttonY-9*buttonSpacing buttonWidth buttonHeight];
            app.ResetButton.Enable = 'off';
            app.ResetButton.ButtonPushedFcn = @(~,~) resetImage(app);

            app.SaveButton = uibutton(app.UIFigure, 'push');
            app.SaveButton.Text = 'Save Image';
            app.SaveButton.Position = [buttonX buttonY-10*buttonSpacing buttonWidth buttonHeight];
            app.SaveButton.Enable = 'off'; 
            app.SaveButton.ButtonPushedFcn = @(~,~) saveImage(app);

        end
    end

    methods (Access = public)

        % Construct app
        function app = GUI_image_processing        
            createComponentss(app);

            % Initialize app
            if nargout == 0
                clear app;
            end
        end

        % Code that executes before app deletion
        function delete(app)
            % Delete UIFigure when app is deleted
            delete(app.UIFigure);
        end
    end
end

