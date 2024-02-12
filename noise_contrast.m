% Contrast Sensitivity Assessment Using Perlin Noise with Dynamic Blending

% Clear the workspace and the screen
sca;
close all;
clearvars;

% Set parameters
numTrials = 10; % Number of trials
stimSize = 256 + 31; % Size of the stimulus (in pixels) (+ 31 is to correct the size of the generated noise)
contrastLevels = logspace(-3, 0, numTrials); % Contrast levels to test (logarithmic spacing)
response = zeros(numTrials, 1); % Participant's response (1 for detected, 0 for not detected)
alphaStep = 0.1; % Step size for changing alpha value
% Set initial alpha value
alphaValue = 0.5;

try
    % Initialize Psychtoolbox
    PsychDefaultSetup(2);
    screens = Screen('Screens');
    screenNumber = max(screens);
    [window, windowRect] = PsychImaging('OpenWindow', screenNumber, 0.5);
    [screenXpixels, screenYpixels] = Screen('WindowSize', window);
    [xCenter, yCenter] = RectCenter(windowRect);
    
    % Set up alpha-blending for smooth (anti-aliased) lines
    Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
    
    % Display stimulus and collect responses
    for trial = 1:numTrials
        % Generate Perlin noise
        perlinNoise = perlin_noise(stimSize, stimSize, 1);
        % Apply contrast to the stimulus
        noisyStimulus = perlinNoise * contrastLevels(trial);
        
        % Make the noise into a texture
        noiseTexture = Screen('MakeTexture', window, noisyStimulus);
        
        
        % Draw stimulus to the window with dynamic blending
        while alphaValue <= 1 && alphaValue >= 0
            % Draw noise texture with dynamic alpha blending
            Screen('DrawTexture', window, noiseTexture, [], [], 0, [], [], [1, 1, 1, alphaValue]);
            Screen('Flip', window);
            
            % Check for response
            [~, ~, keyCode] = KbCheck;
            if keyCode(KbName('1!')) || keyCode(KbName('y'))
                response(trial) = 1;
                % Decrease alpha value if answer is correct
                alphaValue = alphaValue - alphaStep;
            elseif keyCode(KbName('2@')) || keyCode(KbName('n'))
                response(trial) = 0;
                % Increase alpha value if answer is incorrect
                alphaValue = alphaValue + alphaStep;
            end
            
            % Wait for a moment before updating alpha value
            WaitSecs(0.1); % Adjust as needed
        end
        
        % Clear the screen
        Screen('FillRect', window, 0.5);
        Screen('Flip', window);
        
        % Wait for a moment before starting the next trial
        WaitSecs(0.5); % Adjust as needed
    end
    
    % Close the window
    sca;
    
    % Analyze results
    figure;
    plot(log10(contrastLevels), response, 'o-');
    xlabel('Log Contrast Level');
    ylabel('Response (1 for detected, 0 for not detected)');
    title('Contrast Sensitivity Assessment');
    xlim([-3.5, 0.5]);
    ylim([-0.1, 1.1]);
    grid on;
    
catch ME
    % If an error occurs, close the window and rethrow the error
    sca;
    rethrow(ME);
end
