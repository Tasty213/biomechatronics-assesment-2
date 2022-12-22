classdef testData < matlab.unittest.TestCase

    methods (TestClassSetup)
        % Shared setup for the entire test class
    end

    methods (TestMethodSetup)
        % Setup for each test
    end

    methods (Test)
        % Test methods

        function testLoad(testCase)
            expected = [49169, 78];
            data = Data;
            
            actual = size(data.IMU_data);
            
            testCase.verifyEqual(actual,expected)
        end

    end

end