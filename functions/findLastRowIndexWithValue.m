function rowNumber = findLastRowIndexWithValue(table, trial_num, value)
    % Find rows where the value in column X matches
    matchingRows = table.(trial_num) == value;
    
    % Find the last matching row
    lastMatchingRow = find(matchingRows, 1, 'last');
    
    % Return the row number
    rowNumber = lastMatchingRow;
end