function [HC1, HC2, FF1w, FF1b, FF2w, FF2b] = resetCross(AMB_EYE, HCl, HCr, FFLw, FFLb, FFRw, FFRb)
% Resets the cross to the center of the display

if contains(AMB_EYE, 'Left') 
    HC1 = HCl;
    HC2 = HCr;
    FF1w = FFLw;
    FF1b = FFLb;
    FF2w = FFRw;
    FF2b = FFRb;
else
    HC1 = HCr;
    HC2 = HCl;
    FF1w = FFRw;
    FF1b = FFRb;
    FF2w = FFLw;
    FF2b = FFLb;
end

end