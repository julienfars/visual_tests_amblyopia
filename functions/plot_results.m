function plot_results(staircase_ended, table, mean, numstaircase, nb_plot)
    if isempty(numstaircase)
        disp('I hope you are not using multiple staircases; otherwise, you made an error');
    else
        subplot(2, 3, numstaircase);
    end

    if table{1, 3} >= 1
        if ~isempty(numstaircase)
            idx = any(table{:, 'Staircase'} == numstaircase, 2);
            data = table(idx, 7);
        else
            data = table(:, 8);
        end

        data(all(~data{:,:}, 2), :) = [];
        
        if ~isempty(data)
            plot(data{:,:}, 'ro-'); % ro- = r(ed) o(circles) -(solid line)
            if ~isempty(numstaircase)
                if nb_plot == 6
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
                elseif nb_plot == 4
                    switch numstaircase
                        case 1
                            title('0.5 freq')
                        case 2
                            title('1 freq')
                        case 3
                            title('2 freq')
                        case 4
                            title('4 freq')
                        otherwise
                            disp('DO YOU USE MULTIPLE STAIRCASES? IF YES, CHECK ERRORS IN CODE')
                    end
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


