function [dotxL, dotyL, dotcolL, dotxR, dotyR, dotcolR, disparity_arcsec, disparity_pixels] = SQUARE_LOOP(expt, log_disparity, stereocue)
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
        if SQUARE == 1
            dotcolTG = ChooseDotColorsTarget(expt.nTGdots, stereocue);
            dotXpixTGL = dotXpixTG + disparity_pixels / 4; %%%Units in pixels
            dotXpixTGR = dotXpixTG - disparity_pixels / 4; %%%Units in pixels
        else
            dotcolTG = ChooseDotColors(expt.nTGdots);
            dotXpixTGL = dotXpixTG - disparity_pixels / 4; %%%Units in pixels
            dotXpixTGR = dotXpixTG + disparity_pixels / 4; %%%Units in pixels
        end

        % Remove any BG dots which fall in the shifted position of the tgt:
        % Left eye: TARGET_Position is centred on x=tgtxcen-qdisp after the shift, y=tgtycen as no vertical disparity:
        jkeepL = find(~(abs(dotXpixBGL - tgtxcen - disparity_pixels / 4) < (expt.tgtXsizepix) / 2 & ...
                        abs(dotYpixBG1 - tgtycen) < (expt.tgtYsizepix) / 2));
        dotXpixBGL = dotXpixBGL(jkeepL);
        dotYpixBGL = dotYpixBG1(jkeepL);
        dotcolBGL = dotcolBG1(:, jkeepL);

        %disparity_pixels/4Right eye: TARGET_Position is centred on tgtxcen+qdisp after the shift y=tgtycen as no vertical disparity:
        jkeepR = find(~(abs(dotXpixBGR - tgtxcen + disparity_pixels / 4) < (expt.tgtXsizepix) / 2 & ...
                        abs(dotYpixBG1 - tgtycen) < (expt.tgtYsizepix) / 2));
        dotXpixBGR = dotXpixBGR(jkeepR);
        dotYpixBGR = dotYpixBG1(jkeepR);
        dotcolBGR = dotcolBG1(:, jkeepR);

        switch SQUARE
            case 1
                dotxL1 = [dotXpixTGL dotXpixBGL];
                dotxL1 = round(dotxL1); % added --> not working!!!!!
                dotyL1 = [dotYpixTG dotYpixBGL];
                dotyL1 = round(dotyL1); % added
                dotcolL1 = [dotcolTG dotcolBGL];
                dotxR1 = [dotXpixTGR dotXpixBGR];
                dotxR1 = round(dotxR1); % added
                dotyR1 = [dotYpixTG dotYpixBGR];
                dotyR1 = round(dotyR1); % added
                dotcolR1 = [dotcolTG dotcolBGR];
            case 2
                dotxL2 = [dotXpixTGL dotXpixBGL];
                dotxL2 = round(dotxL2); % added
                dotyL2 = [dotYpixTG dotYpixBGL];
                dotyL2 = round(dotyL2); % added
                dotcolL2 = [dotcolTG dotcolBGL];
                dotxR2 = [dotXpixTGR dotXpixBGR];
                dotxR2 = round(dotxR2); % added
                dotyR2 = [dotYpixTG dotYpixBGR];
                dotyR2 = round(dotyR2); % added
                dotcolR2 = [dotcolTG dotcolBGR];
            case 3
                dotxL3 = [dotXpixTGL dotXpixBGL];
                dotxL3 = round(dotxL3); % added
                dotyL3 = [dotYpixTG dotYpixBGL];
                dotyL3 = round(dotyL3); % added
                dotcolL3 = [dotcolTG dotcolBGL];
                dotxR3 = [dotXpixTGR dotXpixBGR];
                dotxR3 = round(dotxR3); % added
                dotyR3 = [dotYpixTG dotYpixBGR];
                dotyR3 = round(dotyR3); % added
                dotcolR3 = [dotcolTG dotcolBGR];
            case 4
                dotxL4 = [dotXpixTGL dotXpixBGL];
                dotxL4 = round(dotxL4); % added
                dotyL4 = [dotYpixTG dotYpixBGL];
                dotyL4 = round(dotyL4); % added
                dotcolL4 = [dotcolTG dotcolBGL];
                dotxR4 = [dotXpixTGR dotXpixBGR];
                dotxR4 = round(dotxR4); % added
                dotyR4 = [dotYpixTG dotYpixBGR];
                dotyR4 = round(dotyR4); % added
                dotcolR4 = [dotcolTG dotcolBGR];
        end
        
    end % for square
        dotxL   = [dotxL   dotxL1   dotxL2   dotxL3   dotxL4];
        dotyL   = [dotyL   dotyL1   dotyL2   dotyL3   dotyL4];
        dotcolL = [dotcolL dotcolL1 dotcolL2 dotcolL3 dotcolL4];
        dotcolL = round(dotcolL);

        dotxR   = [dotxR   dotxR1   dotxR2   dotxR3   dotxR4];
        dotyR   = [dotyR   dotyR1   dotyR2   dotyR3   dotyR4];
        dotcolR = [dotcolR dotcolR1 dotcolR2 dotcolR3 dotcolR4];
        dotcolR = round(dotcolR);
end
