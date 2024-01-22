function [repeatNoise] = drawAttentionCue(window, black, ARROWLT, ...
    ARROWRT, ARROWLB, ARROWRB, penWidthPixels, rectColor, HC1, ...
    waitTime, texSize, xCenter, yCenter, bgcontrast, fgcontrast, ...
    noiseTexture, ARROW_X, ARROW_Y, isConvex, white)
    % Present noise and arrow.

    repeatNoise = true;
    repNOISE = noiseTexture; % Assuming NOISE is a texture

    if contains(AMB_EYE, 'Left')
    % Display arrow shapes
    Screen('SelectStereoDrawBuffer', window, 0);
    Screen('FillRect', window, black, ARROWLT, penWidthPixels);
    Screen('FillRect', window, black, ARROWRT, penWidthPixels);
    Screen('FillRect', window, black, ARROWLB, penWidthPixels);
    Screen('FillRect', window, black, ARROWRB, penWidthPixels);
    Screen('Flip', window);
    WaitSecs(waitTime);

    % Clear arrow shapes
    Screen('SelectStereoDrawBuffer', window, 0);
    Screen('FillRect', window, rectColor*0.5, HC1);
    Screen('Flip', window);
    WaitSecs(waitTime);

    % Display noise and arrow
    Screen('SelectStereoDrawBuffer', window, 1);

    dstGab_centerN = [0 0 1 0.5] .* texSize;
    dstGab_centerN = CenterRectArrayOnPoint(dstGab_centerN, xCenter, yCenter);

    Screen('FillRect', window, [0.5 0.5 0.5 bgcontrast], dstGab_centerN);

    Screen('Blendfunction', window, GL_ONE, GL_ZERO);
    Screen('DrawDots', window, [xCenter yCenter], 1500, [0.5 0.5 0.5 fgcontrast], [], 3); % was 500
    Screen('Blendfunction', window, GL_DST_ALPHA, GL_ONE);

    Screen('DrawTextures', window, repNOISE, [], dstGab_centerN, [], 0);

    Screen('Blendfunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    Screen('FillPoly', window, white, [ARROW_X; ARROW_Y]', isConvex);
    Screen('DrawingFinished', window);
    elseif contains(AMB_EYE, 'Right')

    Screen('SelectStereoDrawBuffer',window,1);
    Screen('FillRect', window, black, ARROWLT,penWidthPixels);
    Screen('FillRect', window, black, ARROWRT,penWidthPixels);
    Screen('FillRect', window, black, ARROWLB,penWidthPixels);
    Screen('FillRect', window, black, ARROWRB,penWidthPixels);
    Screen('Flip', window);
    WaitSecs(waitTime);
    Screen('SelectStereoDrawBuffer',window,1);
    Screen('FillRect', window, rectColor*0.5, HC1);
    Screen('Flip', window);
    WaitSecs(waitTime);


    % put the arrow here 
    Screen('SelectStereoDrawBuffer',window,0);
    dstGab_centerN = [0 0 1 0.5] .* texSize;
    dstGab_centerN = CenterRectArrayOnPoint(dstGab_centerN, xCenter, yCenter);

    Screen('FillRect', window, [0.5 0.5 0.5 bgcontrast], dstGab_centerN);

    Screen('Blendfunction', window, GL_ONE, GL_ZERO);
    Screen('DrawDots', window, [xCenter yCenter], 1500, [0.5 0.5 0.5 fgcontrast], [], 3);
    Screen('Blendfunction', window, GL_DST_ALPHA, GL_ONE);

    Screen('DrawTextures', window, noiseTexture, [], dstGab_centerN, [], 0);

    Screen('Blendfunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    Screen('FillPoly', window, white, [ARROW_X; ARROW_Y]', isConvex);
    Screen('DrawingFinished', window);

    end

end