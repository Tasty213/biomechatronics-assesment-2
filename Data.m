classdef Data
    %DATA this class loads and holds the IMU data
    %   This class wraps the loading and handling of the IMU data

    properties
        IMU_data
        windowSize
        windowInterval
    end

    methods
        function obj = Data(pattern, windowSize, interval)
            arguments
                pattern string = "IMU_Data_for_assignment/**/*.dat";
                windowSize int16 = 1;
                interval int16 = 1;
            end
            %Data Construct an instance of this class
            
            obj.windowInterval = interval;
            obj.windowSize = windowSize;

            files = dir(pattern);
            columns = [];
            for index = 1:length(files)
                file = files(index);
                path = file.folder + "\" + file.name;
                data = obj.readDataFile(path);
                obj.IMU_data{index} = data;
                columns = [columns convertCharsToStrings(data.Properties.VariableNames)];
            end
            obj.IMU_data = obj.IMU_data;
            columns = unique(columns);
            for index = 1:length(obj.IMU_data)
                for column = columns
                    if ~any(strcmp(obj.IMU_data{index}.Properties.VariableNames, column)) 
                        obj.IMU_data{index}.(column) = NaN(size(obj.IMU_data{index}, 1), 1);
                    end
                end
                obj.IMU_data{index} = obj.slidingWindows(interval, obj.IMU_data{index});
            end
            obj.IMU_data = vertcat(obj.IMU_data{:});
        end

        function output = slidingWindows(obj, interval, data)
            windows = { {@max, "max"}; 
                        {@min, "min"}; 
                        {@mean,"mean"}; 
                        {@std, "std"}; 
                        {@rms, "rms"}; 
                        {@zerocrossings, "zcs"}; 
                        {@maxgradient, "mgd"};
                      };
            output = cell(length(windows), 1);
            for index = 1:length(windows)
                output{index} = obj.slidingWindow(windows{index}, data, interval);
            end
            output = horzcat(output{:});
            %output.Time = data.Time;
            output.action(:,1) = convertCharsToStrings(data.action{1});  
        end

        function output = slidingWindow(obj, func, data, interval)    
            func{1} = @(x) movcustom(x, obj.windowSize, interval, func{1});
            
            output = varfun(func{1}, data, "InputVariables", @isnumeric);
            newNames = append(func{2},string(output.Properties.VariableNames));
            output  = renamevars(output ,output.Properties.VariableNames,newNames);
            output  = removevars(output , append(func{2},"Fun_Time"));
        end
    end

    methods ( Static )
        function data = readDataFile(path)
            arguments
                path string;
            end

            data = readtable(path,"ReadVariableNames",true);
            meta = split(path, "\");
            data.action(:,1) = convertCharsToStrings(meta{length(meta) - 1});
            vars = ["Thigh_R","Shank_R","Foot_R", "Thigh_L", "Shank_L", "Foot_L", "Pelvis"];
            data.Time = mean(data{:,vars},2);
            data = removevars(data, vars);
            return
        end

    end
end