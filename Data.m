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
            %   concatenate it into a large table

            files = dir(pattern);
            for index = 1:length(files)
                file = files(index);
                path = file.folder + "\" + file.name;
                obj.IMU_data = [obj.IMU_data; readtable(path,"ReadVariableNames",true)];
            end
        end
    end
end