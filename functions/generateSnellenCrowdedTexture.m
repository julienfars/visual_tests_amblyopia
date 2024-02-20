function [crowd, E_rand_orientation] = generateSnellenCrowdedTexture(window, E_texture)
    % Generate Snellen Crowded Texture
    % This function generates a crowded Snellen E texture for the 'snellen_crowded' case.

    crowd = repmat(E_texture, 1, 5);
    E_rand_num = rand(1, 5);
    E_rand_orientation = zeros(1, 5);
    
    for i = 1:5
        x = E_rand_num(i);
        if x <= 0.25 % for each trial the orientation is set randomly
            orientation = 90;
            E_shape = [0 0 0 0 0; 0 0.5 0 0.5 0 ; 0 0.5 0 0.5 0; 0 0.5 0 0.5 0; 0 0.5 0 0.5 0];
        elseif x > 0.25 && rand <= 0.5 
            orientation = 180;
            E_shape = [0 0 0 0 0; 0.5 0.5 0.5 0.5 0; 0 0 0 0 0; 0.5 0.5 0.5 0.5 0; 0 0 0 0 0];
        elseif x > 0.5 && rand <= 0.75
            orientation = 270;
            E_shape = [0 0.5 0 0.5 0 ; 0 0.5 0 0.5 0; 0 0.5 0 0.5 0; 0 0.5 0 0.5 0; 0 0 0 0 0];
        else 
            orientation = 0;
            E_shape = [0 0 0 0 0; 0 0.5 0.5 0.5 0.5 ; 0 0 0 0 0; 0 0.5 0.5 0.5 0.5; 0 0 0 0 0];
        end
        E_texture = Screen('MakeTexture', window, E_shape);
        E_rand_orientation(1, i) = orientation;
        crowd(1, i) = E_texture;
    end
end