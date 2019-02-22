function BatteryProgram(name,V_nominal,price_unit,capacity,discharge,weight,height,diameter)
    max_volt = 600; % Max Voltage as per SAE rules
    min_volt = 100; %Min Voltage declared by us
    max_power = 40000;%Max Power
    
    max_s = round(max_volt/V_nominal,0); %finding minimum s value as integer
    min_s = round(min_volt/V_nominal,0); %finding max s value
    
    battery_information = []; %initializes the battery_information matrix, not preallocated
    for s = min_s:max_s %iterates from the least amount of series to max amount of series per rules
        total_voltage = s*V_nominal; %voltage at s value
        for p = 1:1000 %runs parallel configurations from 1 to arbitrary 1000, upper limit set higher than likely as an finite roof but loop will never reach 1000
            total_current = p*discharge; %amperage at discharge current
            total_capacity = p*capacity; %Calculates capacity of configuration by multipying capacity of cell by cells in parallel
            total_power = total_voltage*total_current; %Calculating by Power = Voltage*Amperage to Watts
            if total_power >= max_power && total_power <= max_power*1.1 % limits of acceptable values are limited by power and will be between 40kw and 10% more          
                total_cells = s*p; %calculates the amount of cells by multiplying series by parallel
                total_weight = total_cells*weight; %weight per cell * cells
                total_price = price_unit*total_cells;%Calculates total price of pack
                volume_cells= ((((pi/4)*diameter^2)*height)*total_cells);%will find volume in mm^3
                battery_values = [s,p,total_cells,total_price,volume_cells,total_voltage,total_current,total_power,total_capacity,total_weight]; %saves all values into a matrix
                battery_information = [battery_information;battery_values]; %#ok<AGROW> %appends battery values as the next row
            end
        end
    end
    %% Extracting all Optimization Configurations we want
   [~,min_vol_indx] = min(battery_information(:,5)); % returns the minimum volume row index
   min_vol_row = battery_information(min_vol_indx,:); % extracts the row of the minimum volume row index
   
   [~,max_power_indx] = max(battery_information(:,8)); %returns max power index
   max_power_row = battery_information(max_power_indx,:); % extracts the row of the max power row index
   
   [~,max_capacity_indx] = max(battery_information(:,9)); % returns max capacity index
   max_capacity_row = battery_information(max_capacity_indx,:); %extracts the row of the max capacity index
   
% Not used because the minimum price will always be an attribute of the
% least volume pack for each specific cell
%    [~,min_price_indx] = min(battery_information(:,4));
%    min_price_row = battery_information(min_price_indx,:);
   
   %% Making Table from Extracted max and min value rows
   opt_matrix = [min_vol_row;max_power_row;max_capacity_row];
   opt_table = array2table(opt_matrix);
   opt_table.Properties.VariableNames = {'S','P','Cells','Price','Volume','Voltage','Current','Power','Capacity','Weight'};
   opt_table.Properties.RowNames = {'MinVolume','MaxPower','MaxCapacity'};
   fprintf("\n\n\t"+name+"\n");
   disp(opt_table);
   
   config_str = strcat(num2str(opt_matrix(:,1))+"s",num2str(opt_matrix(:,2))+"p");
   cat_config = categorical(config_str);
   
%% Bar Plot for Fun
%    subplot(2,2,1)
%    bar(cat_config(:,1),opt_matrix(:,5));
%    title("Volume");
%    
%    subplot(2,2,2);
%    bar(cat_config(:,1),opt_matrix(:,8));
%    title("Power")
%    
%    subplot(2,2,3)
%    bar(cat_config(:,1),opt_matrix(:,9));
%    title("Capacity")

end
