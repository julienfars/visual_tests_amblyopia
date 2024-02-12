classdef staircase < handle
% Alex S Baldwin - McGill Vision Research - April 2014 - Updated August 2017
% Implementation of a staircase class (object-oriented)
% Create a staircase by calling SC = staircase(...with arguments...)
% Arguments are described under the class constructor function below
% Current stimulus level to test is SC.curLevel
% After a response call SC.doResp(isCorrect) with a Boolean (0 or 1)
% Use SC.isFinished to find out whether the staircase is finished
% You can get your data from SC.levels, SC.nTrials, and SC.nCorrect
% Code downloaded from: https://github.com/alexsbaldwin/MatlabStaircase

    properties % properties of a class are like Matlab struct fields
        levels
        initStepSize
        stepSize
        rightRule
        wrongRule
        maxTrials
        maxRevs
        nTrials
        trialCount   % this is only used in staircase tracking
        nCorrect
        revCount
        curLevel
        curDirection % 0 is descending, 1 is ascending
        curRight
        curWrong
        verbose
        reversals
        ceilingBehaviour
        requestedStartLevel
        didJustReverse
        numCeilingIncrements
        maxCeilingIncrements
        reversalDirections
    end

    properties (Dependent) % these are defined dynamically (see below)
        nLevels
        minLevel
        maxLevel
        curIndex
        curStepSize
        isFinished
        curReversalThresh
        curReversalError
            end

    methods % public (callable) methods (class-specific functions)
        % class constructor function is staircase(...)
        function sc = staircase(levels, initStepSize, stepSize, ...
                                rightRule, wrongRule, maxTrials, ...
                                maxRevs, startLevel, verbose,   ...
                                ceilingBehaviour, maxCeilingIncrements)
            if (nargin > 0)
                % set by inputs
                sc.levels       = levels;       % staircase levels
                sc.initStepSize = initStepSize; % step size before 1st rev
                sc.stepSize     = stepSize;     % subsequent step size
                sc.rightRule    = rightRule;    % n right to make harder
                sc.wrongRule    = wrongRule;    % n wrong to make easier
                sc.maxTrials    = maxTrials;    % max trials to terminate
                sc.maxRevs      = maxRevs;      % max revs to terminate
                sc.verbose      = verbose;      % 1 for console output
                sc.requestedStartLevel = startLevel;
                
                % initialised to zero/empty
                sc.nTrials        = zeros(1,sc.nLevels);
                sc.nCorrect       = zeros(1,sc.nLevels);
                sc.trialCount     = 0;
                sc.revCount       = 0; % reversals counter
                sc.curDirection   = 0;
                sc.curRight       = 0; % number of right responses
                sc.curWrong       = 0; % number of wrong responses
                sc.didJustReverse = 0;
                sc.numCeilingIncrements = 0;
                sc.reversals            = [];
                sc.reversalDirections   = [];
                
                sc.setToNearestLevel(sc.requestedStartLevel);
                if nargin < 10
                    sc.ceilingBehaviour = 'limiting';
                else
                    if strcmp(ceilingBehaviour, 'limiting') || strcmp(ceilingBehaviour, 'resetting')
                        sc.ceilingBehaviour = ceilingBehaviour;
                    else
                        error('Invalid ceiling behaviour, must be "limiting" or "resetting"')
                    end
                end
                
                if nargin < 11
                    sc.maxCeilingIncrements = inf;
                else
                    sc.maxCeilingIncrements = maxCeilingIncrements;
                end
            end
            if sc.verbose
                fprintf('\nStaircase class object initialised.\n')
            end
        end

        function minLevel = get.minLevel(sc) % minimum staircase level
            minLevel = min(sc.levels);
        end

        function maxLevel = get.maxLevel(sc) % maximum staircase level
            maxLevel = max(sc.levels);
        end

        function nLevels = get.nLevels(sc)  % number of staircase levels
            nLevels = length(sc.levels);
        end

        function curIndex = get.curIndex(sc) % current staircase index
            curIndex = find(sc.levels == sc.curLevel);
        end

        function curStepSize = get.curStepSize(sc) % current step size
            if sc.revCount <= 1
                curStepSize = sc.initStepSize;
            elseif sc.revCount == 2
                curStepSize = sc.stepSize;
            elseif sc.revCount == 3
                curStepSize = sc.stepSize/2;
            elseif sc.revCount >= 4
                curStepSize = sc.stepSize/4;
            end
        end
            

        function isFinished = get.isFinished(sc) % check if finished
            isDoneRevs   = sc.revCount>=sc.maxRevs;
            isDoneTrials = sc.trialCount>=sc.maxTrials;
            isDoneCeilingReversals = sc.numCeilingIncrements>=sc.maxCeilingIncrements;
        	isFinished   = isDoneRevs||isDoneTrials||isDoneCeilingReversals;
        end

        function curReversalThresh = get.curReversalThresh(sc)
            if length(sc.reversals) < 3
                curReversalThresh = NaN;
            else
                curReversalThresh = mean(sc.reversals(2:end));
            end
        end

        function curReversalError = get.curReversalError(sc)
            if length(sc.reversals) < 3
                curReversalError = NaN;
            else
                curReversalError = std(sc.reversals(2:end)) / sqrt(length(sc.reversals(2:end)));
            end
        end

        function sc = doResp(sc, isCorrect)
           sc.trialInc;
           sc.didJustReverse = 0;
           switch isCorrect
                case 0
                    sc.curWrong = sc.curWrong + 1;
                    
                    if sc.verbose
                        fprintf('Incorrect response, nWrong = %0.0f\n', ...
                                 sc.curWrong)
                    end
                case 1
                    sc.curRight = sc.curRight + 1;
                    
                    sc.nCorrect(sc.curIndex) = sc.nCorrect(sc.curIndex)+1;
                    if sc.verbose
                        fprintf('Correct response, nRight = %0.0f\n', ...
                                 sc.curRight)
                    end
           end
           sc.checkRules;
        end
    end

    methods (Access = private) % private (not callable) methods

        function sc = trialInc(sc)
            sc.nTrials(sc.curIndex) = sc.nTrials(sc.curIndex) + 1;
            %{
            if sc.revCount == 0
                if sc.verbose
                    fprintf('No reversals yet so do not count trials\n')
                end
            else
            %}
                sc.trialCount = sc.trialCount+1; % increment the counter
                if sc.verbose                    % only after 1st reversal
                    fprintf('Reversal: %0.0f, Trial: %0.0f\n', ...
                             sc.revCount,  sc.trialCount)
                end
            %end
        end


        function sc = setToNearestLevel(sc,reqLevel)
            absDiff = abs(sc.levels - reqLevel);
            sc.curLevel = sc.levels(absDiff==min(absDiff));
        end

        function sc = checkRules(sc) % inc/dec staircase if rules exceeded
            if sc.curRight >= sc.rightRule
                if sc.verbose
                    fprintf('Change level: increase.\n')
                end
                sc.changeLevel(1);

            elseif sc.curWrong >= sc.wrongRule
                if sc.verbose
                    fprintf('Change level: decrease.\n')
                end
                sc.changeLevel(0);
            end
        end

        function sc = changeLevel(sc, newDir)

            if sc.curDirection ~= newDir  % if changed direction then
                sc.doReversal(newDir);    % count reversal
            end

            switch sc.curDirection % change staircase level
                case 0
                    sc.curLevel = sc.curLevel - sc.curStepSize;
                case 1
                    sc.curLevel = sc.curLevel + sc.curStepSize;
            end

            if sc.curLevel > sc.maxLevel     % keep staircase level
                sc.numCeilingIncrements = sc.numCeilingIncrements + 1;
                switch sc.ceilingBehaviour
                    case 'limiting'
                        sc.curLevel = sc.maxLevel;   % within limits
                        if sc.verbose
                            fprintf('Max exceeded %0.0f time(s), bound at %0.0f.\n', sc.numCeilingIncrements, sc.curLevel)
                        end
                    case 'resetting'
                        sc.setToNearestLevel(sc.requestedStartLevel);
                        if sc.verbose
                            fprintf('Max exceeded %0.0f time(s), resetting to %0.2f.\n', sc.numCeilingIncrements, sc.requestedStartLevel)
                        end
                end
            elseif sc.curLevel < sc.minLevel
                switch sc.ceilingBehaviour
                    case 'limiting'
                        sc.curLevel = sc.minLevel;
                        if sc.verbose
                            fprintf('Min exceeded, bound at %0.0f.\n', sc.curLevel)
                        end
                    case 'resetting'
                        sc.setToNearestLevel(sc.requestedStartLevel);
                        if sc.verbose
                            fprintf('Min exceeded, resetting to %0.2f.\n', sc.requestedStartLevel)
                        end
                end
            else
                if sc.verbose
                    fprintf('Level changed to %0.0f.\n', sc.curLevel)
                end
            end

            sc.curRight = 0;
            sc.curWrong = 0;

        end

        function sc = doReversal(sc, newDir) % count reversal and
        	sc.revCount = sc.revCount + 1;   % change direction
            sc.reversals(end+1)          = sc.curLevel;
            sc.reversalDirections(end+1) = newDir;
            if sc.verbose
                fprintf('Reversal, %0.0f to %0.0f, revCount = %0.0f, revThresh = %0.1f +/- %0.1f\n', ...
                        sc.curDirection, newDir, sc.revCount, sc.curReversalThresh, sc.curReversalError)
            end
            sc.curDirection   = newDir;
            sc.didJustReverse = 1;
        end

    end

end


%{
classdef Staircase < handle
    % Staircase: A class for implementing a staircase procedure for visual experiments.
    %
    % Usage:
    %   Create a staircase object: SC = Staircase(...with arguments...)
    %   - Arguments are described under the class constructor function below.
    %   - Current stimulus level to test is SC.curLevel.
    %   - After a response, call SC.doResp(isCorrect) with a Boolean (0 or 1).
    %   - Use SC.isFinished to check if the staircase is finished.
    %   - Access data using SC.levels, SC.nTrials, and SC.nCorrect.

    properties
        % Properties of the Staircase class
        levels
        initStepSize
        stepSize
        rightRule
        wrongRule
        maxTrials
        maxRevs
        nTrials
        trialCount
        nCorrect
        revCount
        curLevel
        curDirection
        curRight
        curWrong
        verbose
        reversals
        ceilingBehaviour
        requestedStartLevel
        didJustReverse
        numCeilingIncrements
        maxCeilingIncrements
        reversalDirections
    end

    properties (Dependent)
        % Dependent properties
        nLevels
        minLevel
        maxLevel
        curIndex
        curStepSize
        isFinished
        curReversalThresh
        curReversalError
    end

    methods
        % Public methods

        function obj = Staircase(levels, initStepSize, stepSize, ...
                                rightRule, wrongRule, maxTrials, ...
                                maxRevs, startLevel, verbose, ...
                                ceilingBehaviour, maxCeilingIncrements)
            % Constructor method for the Staircase class
            if nargin > 0
                obj.levels = levels;
                obj.initStepSize = initStepSize;
                obj.stepSize = stepSize;
                obj.rightRule = rightRule;
                obj.wrongRule = wrongRule;
                obj.maxTrials = maxTrials;
                obj.maxRevs = maxRevs;
                obj.verbose = verbose;
                obj.requestedStartLevel = startLevel;

                obj.nTrials = zeros(1, obj.nLevels);
                obj.nCorrect = zeros(1, obj.nLevels);
                obj.trialCount = 0;
                obj.revCount = 0;
                obj.curDirection = 0;
                obj.curRight = 0;
                obj.curWrong = 0;
                obj.didJustReverse = 0;
                obj.numCeilingIncrements = 0;
                obj.reversals = [];
                obj.reversalDirections = [];

                obj.setToNearestLevel(obj.requestedStartLevel);
                
                if nargin < 10
                    obj.ceilingBehaviour = 'limiting';
                else
                    if strcmp(ceilingBehaviour, 'limiting') || strcmp(ceilingBehaviour, 'resetting')
                        obj.ceilingBehaviour = ceilingBehaviour;
                    else
                        error('Invalid ceiling behaviour, must be "limiting" or "resetting"')
                    end
                end

                if nargin < 11
                    obj.maxCeilingIncrements = inf;
                else
                    obj.maxCeilingIncrements = maxCeilingIncrements;
                end
            end
            if obj.verbose
                fprintf('\nStaircase class object initialised.\n')
            end
        end

        function minLevel = get.minLevel(obj)
            % Getter method for the minimum staircase level
            minLevel = min(obj.levels);
        end

        function maxLevel = get.maxLevel(obj)
            % Getter method for the maximum staircase level
            maxLevel = max(obj.levels);
        end

        function nLevels = get.nLevels(obj)
            % Getter method for the number of staircase levels
            nLevels = length(obj.levels);
        end

        function curIndex = get.curIndex(obj)
            % Getter method for the current staircase index
            curIndex = find(obj.levels == obj.curLevel);
        end

        function curStepSize = get.curStepSize(obj)
            % Getter method for the current step size
            if obj.revCount <= 1
                curStepSize = obj.initStepSize;
            elseif obj.revCount == 2
                curStepSize = obj.stepSize;
            elseif obj.revCount == 3
                curStepSize = obj.stepSize / 2;
            elseif obj.revCount >= 4
                curStepSize = obj.stepSize / 4;
            end
        end

        function isFinished = get.isFinished(obj)
            % Getter method to check if the staircase is finished
            isDoneRevs = obj.revCount >= obj.maxRevs;
            isDoneTrials = obj.trialCount >= obj.maxTrials;
            isDoneCeilingReversals = obj.numCeilingIncrements >= obj.maxCeilingIncrements;
            isFinished = isDoneRevs || isDoneTrials || isDoneCeilingReversals;
        end

        function curReversalThresh = get.curReversalThresh(obj)
            % Getter method for the current reversal threshold
            if length(obj.reversals) < 3
                curReversalThresh = NaN;
            else
                curReversalThresh = mean(obj.reversals(2:end));
            end
        end

        function curReversalError = get.curReversalError(obj)
            % Getter method for the current reversal error
            if length(obj.reversals) < 3
                curReversalError = NaN;
            else
                curReversalError = std(obj.reversals(2:end)) / sqrt(length(obj.reversals(2:end)));
            end
        end

        function obj = doResp(obj, isCorrect)
            % Method to handle response and update staircase
            obj.trialInc;
            obj.didJustReverse = 0;
            switch isCorrect
                case 0
                    obj.curWrong = obj.curWrong + 1;
                    if obj.verbose
                        fprintf('Incorrect response, nWrong = %0.0f\n', obj.curWrong)
                    end
                case 1
                    obj.curRight = obj.curRight + 1;
                    obj.nCorrect(obj.curIndex) = obj.nCorrect(obj.curIndex) + 1;
                    if obj.verbose
                        fprintf('Correct response, nRight = %0.0f\n', obj.curRight)
                    end
            end
            obj.checkRules;
        end
    end

    methods (Access = private)
        % Private methods

        function obj = trialInc(obj)
            % Method to increment trial count
            obj.nTrials(obj.curIndex) = obj.nTrials(obj.curIndex) + 1;
            obj.trialCount = obj.trialCount + 1;
            if obj.verbose
                fprintf('Trial: %0.0f\n', obj.trialCount)
            end
        end

        function obj = setToNearestLevel(obj, reqLevel)
            % Method to set current level to the nearest staircase level
            absDiff = abs(obj.levels - reqLevel);
            obj.curLevel = obj.levels(absDiff == min(absDiff));
        end

        function obj = checkRules(obj)
            % Method to check rules and adjust staircase if necessary
            if obj.curRight >= obj.rightRule
                if obj.verbose
                    fprintf('Change level: increase.\n')
                end
                obj.changeLevel(1);
            elseif obj.curWrong >= obj.wrongRule
                if obj.verbose
                    fprintf('Change level: decrease.\n')
                end
                obj.changeLevel(0);
            end
        end

        function obj = changeLevel(obj, newDir)
            % Method to change staircase level
            if obj.curDirection ~= newDir
                obj.doReversal(newDir);
            end

            switch obj.curDirection
                case 0
                    obj.curLevel = obj.curLevel - obj.curStepSize;
                case 1
                    obj.curLevel = obj.curLevel + obj.curStepSize;
            end

            if obj.curLevel > obj.maxLevel
                obj.handleCeilingBehaviour('limiting');
            elseif obj.curLevel < obj.minLevel
                obj.handleCeilingBehaviour('resetting');
            else
                if obj.verbose
                    fprintf('Level changed to %0.0f.\n', obj.curLevel)
                end
            end

            obj.curRight = 0;
            obj.curWrong = 0;
        end

        function obj = handleCeilingBehaviour(obj, behaviour)
            % Method to handle ceiling behaviour
            switch behaviour
                case 'limiting'
                    obj.curLevel = min(obj.curLevel, obj.maxLevel);
                    if obj.verbose
                        fprintf('Max exceeded, bound at %0.0f.\n', obj.curLevel)
                    end
                case 'resetting'
                    obj.setToNearestLevel(obj.requestedStartLevel);
                    if obj.verbose
                        fprintf('Max exceeded, resetting to %0.2f.\n', obj.requestedStartLevel)
                    end
            end
        end

        function obj = doReversal(obj, newDir)
            % Method to perform a reversal
            obj.revCount = obj.revCount + 1;
            obj.reversals(end+1) = obj.curLevel;
            obj.reversalDirections(end+1) = newDir;
            if obj.verbose
                fprintf('Reversal, revCount = %0.0f, revThresh = %0.1f +/- %0.1f\n', ...
                        obj.revCount, obj.curReversalThresh, obj.curReversalError)
            end
            obj.curDirection = newDir;
            obj.didJustReverse = 1;
        end
    end
end

%}