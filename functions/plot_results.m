function plot_results(staircase_ended, table, mean, numstaircase)

%will maybe become the analysis script for most of the tests (just to get a glance of the results)
%must be launched at each iteration 



figure(1)

if isempty(numstaircase) == 0
    switch numstaircase
        case 1
            subplot(2,3,1)
        case 2
            subplot(2,3,2)
        case 3
            subplot(2,3,3)
        case 4
            subplot(2,3,4)
        case 5
            subplot(2,3,5)
        case 6
            subplot(2,3,6)
        otherwise
            disp('DO YOU USE MULTIPLE STAIRCASES? IF YES, CHECK ERRORS IN CODE')
    end
        if table{1,1} >= 1
            idx = any(table{:,1} == numstaircase,2); 
            data = table(idx,:);
            data = data{:,{'Level'}};
            if isempty(numstaircase) == 0
                data( all(~data,2), : ) = [];                
            else
                data = data{:,:};
            end
        end
else
    disp('I hope you are not using multiple staircases, otherwise you made an error')
    if table{1,1} >= 1
        data = table(:,{'Level'});
        if isempty(numstaircase) == 0
            data( all(~data,2), : ) = [];                
        else
            data = data{:,:};
        end
    end
end

if table{1,1} >= 1
    plot(data,'ro-'); %ro- = r(ed) o(circles) -(solid line)
        if isempty(numstaircase) == 0
            switch numstaircase
                case 1
                    title('1/16 of Cut-off')
                case 2
                    title('1/8 of Cut-off')
                case 3
                    title('1/4 of Cut-off')
                case 4
                    title('1/2 of Cut-off')
                case 5
                    title('3/4 of Cut-off')
                case 6
                    title('Cut-off')
                otherwise
                    disp('DO YOU USE MULTIPLE STAIRCASES? IF YES, CHECK ERRORS IN CODE')
            end
        else
            disp('I hope you are not using multiple staircases, otherwise you made an error')
        end
    xlabel('Trials')
    ylabel('Value')

%no axis limits defined - to make it more flexible 

    if staircase_ended  
    strmin = ['Mean of last reversals = ',num2str(mean)];
    text(30,2.7,strmin,'HorizontalAlignment','left','EdgeColor','black','FontSize',9,'Fontname','Times New Roman');
    end 

pause(0.01)
end 


