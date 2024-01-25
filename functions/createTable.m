function temps = createTable(maxNumTrials, nb_table, varTypes, varNames)
    % Create a table based on the specified parameters
    
    % Default variable names
    defaultVarNames = ["Task", "Date_time", "Trial", "Reversal", "AMB_eye", "Eye_tested", "Contrast", "Frequency_dva", ...
                       "Orientation", "Position", "Key", "Success", "RT"];

    % Use default variable types if not provided
    if nargin < 3
        varTypes = ["string", "datetime", "double", "double", "string", "string", "double", ...
                    "double", "double", "string", "string", "string", "double"];
    end

    % Use default variable names if not provided
    if nargin < 4
        varNames = defaultVarNames;
    end

    % Calculate table size
    sz = [(maxNumTrials + 7) * nb_table; numel(varNames)]; % preallocating rows

    % Create the table
    temps = table('Size', sz, 'VariableTypes', varTypes, 'VariableNames', varNames);
end