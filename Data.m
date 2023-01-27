classdef Data
    %DATA this class loads and holds the IMU data
    %   This class wraps the loading and handling of the IMU data

    properties
        IMU_data
        windowSize
        windowInterval
    end

    methods
        function obj = Data(pattern, windowSize, interval, drop, window, fillNan)
            arguments
                pattern string = "IMU_Data_for_assignment/**/*.dat";
                windowSize int16 = 1;
                interval int16 = 1;
                drop = {};
                window logical = false;
                fillNan logical = false;
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
                obj.IMU_data{index} = removevars(obj.IMU_data{index}, drop);
                if window
                    obj.IMU_data{index} = obj.slidingWindows(obj.IMU_data{index}, interval, windowSize);
                end
            end
            obj.IMU_data = vertcat(obj.IMU_data{:});
            obj.IMU_data.action = categorical(obj.IMU_data.action);
            if fillNan
                obj.IMU_data = fillmissing(obj.IMU_data, "nearest");
            end
        end

        function output = slidingWindows(obj, data, interval, windowSize)
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
                output{index} = obj.slidingWindow(windows{index}, data, interval, windowSize);
            end
            output = horzcat(output{:});
            %output.Time = data.Time;
            output.action(:,1) = convertCharsToStrings(data.action{1});  
        end

        function output = slidingWindow(obj, func, data, interval, windowSize)    
            func{1} = @(x) movcustom(x, windowSize, interval, func{1});
            
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
            data.file(:,1) = path;
            return
        end

    end
end