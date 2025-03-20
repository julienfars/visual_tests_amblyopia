function [HC1, HC2] = determineMovingSide(AMB_EYE, HCl, HCr)
    % Determine which side of the crosses will be moving.

    if contains(AMB_EYE, 'Left')
        HC1 = HCl;
        HC2 = HCr;
    else
        HC1 = HCr;
        HC2 = HCl;
    end
end