function plot_results(staircase_ended, table, mean, numstaircase)
    if isempty(numstaircase)
        disp('I hope you are not using multiple staircases; otherwise, you made an error');
    else
        subplot(2, 3, numstaircase);
    end

    if table{1, 3} >= 1
        if ~isempty(numstaircase)
            idx = any(table{:, 'Staircase'} == numstaircase, 2);
            data = table(idx, 8);
        else
            data = table(:, 7);
        end

        data(all(~data{:,:}, 2), :) = [];
        
        if ~isempty(data)
            plot(data{:,:}, 'ro-'); % ro- = r(ed) o(circles) -(solid line)
            if ~isempty(numstaircase)
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
                disp('I hope you are not using multiple staircases; otherwise, you made an error');
            end

            xlabel('Trials');
            ylabel('Value');

            % no axis limits defined - to make it more flexible
            if staircase_ended
                strmin = ['Mean of last reversals = ', num2str(mean)];
                text(30, 2.7, strmin, 'HorizontalAlignment', 'left', 'EdgeColor', 'black', 'FontSize', 9, 'Fontname', 'Times New Roman');
            end

            pause(0.01);
        end
    end
end


