function [dotxL, dotyL, dotcolL, dotxR, dotyR, dotcolR, disparity_arcsec, disparity_pixels] = square_loop_asteroid(expt, log_disparity, stereocue, randposition)
    % This function sets up other parameters related to the asteroid experiment.

    dotxL = [];
    dotyL = [];
    dotcolL = [];
    
    dotxR = [];
    dotyR = [];
    dotcolR = [];

    for SQUARE = 1:4
        Position = randposition(SQUARE);

        disparity_arcsec = (10^log_disparity);
        disparity_pixels = ((10^log_disparity) * expt.nx) / (expt.degreesfullscreenX * 3600); %%PIXELS

        tgtxcen = expt.tgtxcen(Position);
        tgtycen = expt.tgtycen(Position);

        % Background dots:
        % Pick random locations:
        dotXpixBG = rand(1, expt.nBGdots) * expt.stimNpixX;
        dotYpixBG = rand(1, expt.nBGdots) * expt.stimNpixY;
        dotcolBG = ChooseDotColors(expt.nBGdots);

        % TARGET_Position patch of dots:
        % Generate random dot positions for TGT
        dotXpixTG = tgtxcen - expt.tgtXsizepix / 2 + rand(1, expt.nTGdots) * expt.tgtXsizepix;
        dotYpixTG = tgtycen - expt.tgtYsizepix / 2 + rand(1, expt.nTGdots) * expt.tgtYsizepix;

        dotXpixBG1 = tgtxcen - expt.BGXsizepix / 2 + rand(1, expt.nBGdots) * expt.BGXsizepix;
        dotYpixBG1 = tgtycen - expt.BGYsizepix / 2 + rand(1, expt.nBGdots) * expt.BGYsizepix;
        dotcolBG1 = ChooseDotColors(expt.nBGdots);

        % Now apply the disparity: We apply -disp/2 to the bg  and +bg/2 to the tgt so
        % that the relative disparity is as specified.
        dotXpixBGL = dotXpixBG1 - disparity_pixels / 4; %%%Units in pixels
        dotXpixBGR = dotXpixBG1 + disparity_pixels / 4; %%%Units in pixels
        dotcolTG = ChooseDotColorsTarget(expt.nTGdots, stereocue);

        if SQUARE == 1
            dotXpixTGL = dotXpixTG + disparity_pixels / 4; %%%Units in pixels
            dotXpixTGR = dotXpixTG - disparity_pixels / 4; %%%Units in pixels
        else
            dotXpixTGL = dotXpixTG - disparity_pixels / 4; %%%Units in pixels
            dotXpixTGR = dotXpixTG + disparity_pixels / 4; %%%Units in pixels
        end

        % Remove any BG dots which fall in the shifted position of the tgt:
        % Left eye: TARGET_Position is centred on x=tgtxcen-qdisp after the shift, y=tgtycen as no vertical disparity:
        jkeepL = ~(abs(dotXpixBGL - tgtxcen - disparity_pixels / 4) < (expt.tgtXsizepix) / 2 & ...
                        abs(dotYpixBG1 - tgtycen) < (expt.tgtYsizepix) / 2);
        dotXpixBGL = dotXpixBGL(jkeepL);
        dotYpixBGL = dotYpixBG1(jkeepL);
        dotcolBGL = dotcolBG1(:, jkeepL);

        %disparity_pixels/4Right eye: TARGET_Position is centred on tgtxcen+qdisp after the shift y=tgtycen as no vertical disparity:
        jkeepR = ~(abs(dotXpixBGR - tgtxcen + disparity_pixels / 4) < (expt.tgtXsizepix) / 2 & ...
                        abs(dotYpixBG1 - tgtycen) < (expt.tgtYsizepix) / 2);
        dotXpixBGR = dotXpixBGR(jkeepR);
        dotYpixBGR = dotYpixBG1(jkeepR);
        dotcolBGR = dotcolBG1(:, jkeepR);

        dotxL = [dotxL dotXpixTGL dotXpixBGL];
        dotyL = [dotyL dotYpixTG dotYpixBGL];
        dotcolL = [dotcolL dotcolTG dotcolBGL];
        
        dotxR = [dotxR dotXpixTGR dotXpixBGR];
        dotyR = [dotyR dotYpixTG dotYpixBGR];
        dotcolR = [dotcolR dotcolTG dotcolBGR];
    end % for square

    dotcolL = round(dotcolL);
    dotcolR = round(dotcolR);
    dotxL = round(dotxL);
    dotyL = round(dotyL);
    dotxR = round(dotxR);
    dotyR = round(dotyR);
end

