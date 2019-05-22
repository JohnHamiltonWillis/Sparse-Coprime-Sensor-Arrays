function [opt_coprime_array] = CoprimeLayoutOptimizer(sensor_layout)
% Function to use to determine the best possible coprime pairs to reduce
% PSL height. This function currently isn't hooked up to the data required 
% for comparisons. Once data is finished generating, this function will be
% updated.
opt_coprime_spec = [0 0 0];
for spacing = 1:63
    % Iterate through all the coprime pair spacings and generate pairs
    cpairs = GenerateCoprimePairs(2,64, spacing);
    for pair = 1:length(cpairs)
        % Iterate through all the coprime pairs
        for period1 = 1:floor(array_length/cpairs{pair}(1))
            % Iterate through all the period extensions that fit in the
            % full sensor array for subarray1
            max_sensor1 = period*cpairs{pair}(1);
            for period2 = 1:floor(array_length/cpairs{pair}(2))
                % Iterate through all the period extensions that fit in the
                % full sensor array for subarray2
                max_sensor2 = period*cpairs{pair}(2);
                % Create the coprime layout necessary for a given coprime
                % pair and their subarrays extensions
                coprime_array = CoprimeArray(max_sensor1,max_sensor2,cpairs{pair}(1),cpairs{pair}(2));
                for shift = 1:(array_length-length(coprime_array))
                    % Shift coprime array from the beginning to the end of
                    % the full array
                    coprime_array = [0 coprime_array];
                    % Check if the proper sensors are available for coprime
                    % array
                    eligible = true;
                    for sensor = 1:length(coprime_array)             
                        if ((coprime_array(sensor)==1) && (sensor_layout(sensor)==0))
                            eligible = false;
                            break
                        end
                    end
                end
                % Store best coprime layout
                if eligible == true
                    % Pull PSL data
                    load(['C:\Users\Work\Downloads\2_100_' num2str(spacing) '.mat'], 'Z')
                    coprime_spec = Z(pair, period);
                    % Store the highest PSL difference
                    if coprime_spec(3) > opt_coprime_spec(3)
                        opt_coprime_spec = coprime_spec;
                    end
                end
            end
        end
    end
end
opt_coprime_array = CoprimeArray(opt_coprime_spec(1),opt_coprime_spec(2),64);