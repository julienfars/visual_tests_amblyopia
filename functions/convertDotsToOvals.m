function [ovalarrayL, ovalarrayR] = convertDotsToOvals(dotarrayL, dotarrayR, cen_L, cen_R, expt, dotcolL, dotcolR)
    % Calculate the number of ovals
    n_ovals_L = size(dotcolL,2);
    n_ovals_R = size(dotcolR,2);
    n_ovals = max([n_ovals_L, n_ovals_R]);

    % Define oval size
    ovalsizepix = [expt.dotsizepix / 2; expt.dotsizepix];

    % Initialize oval arrays
    ovalarrayL = ones(4, n_ovals_L); % will fill the [rect] parameter
    ovalarrayR = ones(4, n_ovals_R);

    for ov = 1:n_ovals
        if ov <= length(dotarrayL)
            x = dotarrayL(1, ov) + cen_L(1);
            y = dotarrayL(2, ov) + cen_L(2);
            X1 = x - 12;
            X2 = x + 12;
            Y1 = y - 6;
            Y2 = y + 6;
            ovalarrayL(:, ov) = [X1; Y1; X2; Y2];
        end

        if ov <= length(dotarrayR)
            x = dotarrayR(1, ov) + cen_R(1);
            y = dotarrayR(2, ov) + cen_R(2);
            X1 = x - 12;
            X2 = x + 12;
            Y1 = y - 6;
            Y2 = y + 6;
            ovalarrayR(:, ov) = [X1; Y1; X2; Y2];
        end
    end
end