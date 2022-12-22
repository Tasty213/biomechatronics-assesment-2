clear();
data = Data("IMU_Data_for_assignment/**/*.dat", 400, 50);
writetable(data.IMU_data, "output.xlsx")