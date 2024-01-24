function E_texture = preallocate_Snellen_texture(window)
    % Preallocate Snellen E texture
    % This function creates and returns the texture for the Snellen E shape.

    % Basic Snellen parameters
    % Here we set the size of the lines of our Snellen E --> then we create
    % a texture, because we can then change its size and orientation
    E_shape = [0 0 0 0 0; 0 0.5 0.5 0.5 0.5; 0 0 0 0 0; 0 0.5 0.5 0.5 0.5; 0 0 0 0 0]; % 0.5 is for grey and 0 is for black

    % Make the shape into a texture (5 x 5 pixels)
    E_texture = Screen('MakeTexture', window, E_shape);
    % size of the Snellen E must be determined by the optotypes
end