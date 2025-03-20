function mrt = createMRTTable(maxNumReversals, nb_table, staircase_type)
    % Create a table for storing mean reversal values
    
    % Default variable names and types
    defaultVarNames = ["ReversalNumber", "Value"];
    defaultVarTypes = ["double", "double", "double"];

    % Use default variable names and types if not provided
    if nargin < 2
        varNames = defaultVarNames;
        varTypes = defaultVarTypes;
    else
        % Customize variable names and types based on the scenario
        switch staircase_type
            case 'simple'
                varNames = ["ReversalNumber", "Value"];
                varTypes = ["double", "double"];
            case 'interleaved'
                varNames = ["ReversalNumber", "Value", "Staircase", "Contrast"];
                varTypes = ["double", "double", "double", "double"];
            % Add more scenarios as needed
            otherwise
                varNames = defaultVarNames;
                varTypes = defaultVarTypes;
        end
    end

    % Calculate table size
    sz = [maxNumReversals * nb_table + 1; numel(varNames)];

    % Create the table
    mrt = table('Size', sz, 'VariableTypes', varTypes, 'VariableNames', varNames);
end