function [E_min_size_dva, global_param] = calculateOptotypeSize(windowRect, global_param, DISTANCE, fixCross)
    % Calculate optotype size.

    DIM_Screen_hor = windowRect(3)/global_param.screen_size(1);
    DIM_Screen_ver = windowRect(4)/global_param.screen_size(2);
    pix_size = 1/DIM_Screen_hor;
    E_min_size = 5*pix_size;
    E_min_size_dva = 2*atand((E_min_size/2)/DISTANCE);

    global_param.MAR_min_theory = 2*atand((pix_size/2)/DISTANCE) * 60;
    global_param.logMAR_min_theory = log10(global_param.MAR_min_theory);

%     MAR_min_theory = 2*atand((((1/(1920/700))*20)/2)/2500)*60;
%     logMAR_min_theory = log10(MAR_min_theory); % should be 0.0012 => 6/6
%     or 20/20 Snellen

    opto_size = [];

%     if fixCross == false
%         [min_res, ~] = min(windowRect(3:4));
%         max_opto_size = round(min_res/5, -1) - 2;
%     else
        [min_res, ~] = min(windowRect(3:4));
        max_opto_size = round((min_res/2)/5, -1) - 2;
%     end
    global_param.max_opto_size = max_opto_size;
end