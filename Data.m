classdef Data
    %DATA this class loads and holds the IMU data
    %   This class wraps the loading and handling of the IMU data

    properties
        IMU_data
    end

    methods
        function obj = Data(pattern)
            arguments
                pattern string = "IMU_Data_for_assignment/**/*.dat";
            end
            %Data Construct an instance of this class
            %   Find all the data within the specified folder and
            %   load into a cell array. Get all the columns of all the
            %   tables and use this to get a list of all possible columns.
            %   Inset N/A columns for any tables that are missing
            %   columns. Concatenate all the tables together and save as
            %   IMU_data.

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
                data = obj.IMU_data{index};
                for column = columns
                    if ~any(strcmp(data.Properties.VariableNames, column)) 
                        obj.IMU_data{index}.(column) = NaN(size(data, 1), 1);
                    end
                end
            end
            obj.IMU_data = vertcat(obj.IMU_data{:});
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