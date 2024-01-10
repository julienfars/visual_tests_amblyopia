function[MAR, logMAR] = convert_logmar(optotype, distance, stereo, pix)

            MAR = 2*atand((optotype*pix/2)/distance) * 60; 
            logMAR = log10(MAR);
 
    end