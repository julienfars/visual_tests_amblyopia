function mt = createMTTable(nb_table, staircase_type)
    % Create a table for storing mean reversal values
    
    % Default variable names and types
    defaultVarNames = ["Staircase", "Fraction", "Frequency", "MEAN"];
    defaultVarTypes = ["double", "double", "double", "double"];

    % Use default variable names and types if not provided
    if nargin < 2
        varNames = defaultVarNames;
        varTypes = defaultVarTypes;
    else
        % Customize variable names and types based on the scenario
        switch staircase_type
            case 'interleaved'
                varNames = ["Staircase", "Fraction", "Frequency", "MEAN"];
                varTypes = ["double", "double", "double", "double"];
            % Add more scenarios as needed
            otherwise
                varNames = defaultVarNames;
                varTypes = defaultVarTypes;
        end
    end

    % Calculate table size
    sz = [nb_table + 1; numel(varNames)]; % preallocating and adding 1 row just to be sure

    % Create the table
    mt = table('Size', sz, 'VariableTypes', varTypes, 'VariableNames', varNames);
end