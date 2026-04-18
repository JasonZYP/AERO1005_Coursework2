% ==================== temp_monitor.m Temperature Monitoring Function ====================
% TEMP_MONITOR Real-time temperature monitoring and tiered LED indicator function
% Usage: temp_monitor(arduino_obj)
% Input Parameters: arduino_obj - Initialised Arduino object from the main script
% Functionality:
%   1. Acquire temperature from MCP9700A sensor every 1 second, with live plot update
%   2. Control LEDs per temperature range: 18-24°C green solid ON, <18°C yellow 0.5s blink, >24°C red 0.25s blink
% Author: Haomiao Zhu 20721147
% Version: 1.0
% Date: 17/4/2026
function temp_monitor(arduino_obj)

%% 1. Input Parameter Validation
if nargin < 1
    error('Please pass an initialised Arduino object! Usage: temp_monitor(a)');
end
if ~isvalid(arduino_obj)
    error('Invalid Arduino object! Initialise the object in the main script first.');
end

%% 2. Pin and Parameter Definition
% Sensor parameters
temp_sensor_pin = 'A0';
V0 = 0.5;
TC = 0.01;
% LED Pins
green_led_pin = 'D2';
yellow_led_pin = 'D3';
red_led_pin = 'D4';
% Timing Parameters
sample_interval = 1;
yellow_blink_period = 0.5;
red_blink_period = 0.25;
% Comfort Temperature Range
temp_min = 18;
temp_max = 24;

%% 3. Initialise Live Plot
start_time = datetime('now');

figure('Name','Real-Time Temperature Monitoring Curve','NumberTitle','off');

time_data = 0;
temp_data = 25;

temp_plot = plot(time_data, temp_data, 'r-', 'LineWidth', 1.5);
hold on; 
grid on;
xlabel('Time (s)', 'FontSize', 12);
ylabel('Temperature (°C)', 'FontSize', 12);
title('Capsule Temperature Real-Time Monitoring', 'FontSize', 14);
ylim([0 40]);
xlim([0 60]);

%% 4. Initialise LEDs (All OFF)
writeDigitalPin(arduino_obj, green_led_pin, 0);
writeDigitalPin(arduino_obj, yellow_led_pin, 0);
writeDigitalPin(arduino_obj, red_led_pin, 0);

%% 5. Infinite Loop for Real-Time Monitoring
fprintf('===== REAL-TIME TEMPERATURE MONITORING STARTED =====\n');
fprintf('Comfort Temperature Range: %.1f°C - %.1f°C\n', temp_min, temp_max);
fprintf('Press Ctrl+C to stop monitoring\n');
fprintf('Time(s)\tTemp(°C)\tStatus\n');

% Timestamp control for LED blinking
last_yellow_toggle = datetime('now');
last_red_toggle = datetime('now');
yellow_led_state = 0;
red_led_state = 0;

try
    while true
        % 1. Acquire Temperature
        current_runtime = seconds(datetime('now') - start_time);
        current_voltage = readVoltage(arduino_obj, temp_sensor_pin);
        current_temp = (current_voltage - V0) / TC;
        
        % 2. Update data arrays
        time_data = [time_data, current_runtime];
        temp_data = [temp_data, current_temp];
        
        %3. Update Live Plot
        if ishandle(temp_plot) 
            set(temp_plot, 'XData', time_data, 'YData', temp_data);
            if current_runtime > 60
                xlim([current_runtime - 60, current_runtime]);
            end
            drawnow; 
        end
        
        % 4. LED Control Logic
        writeDigitalPin(arduino_obj, green_led_pin, 0);
        status_str = '';
        
        if current_temp >= temp_min && current_temp <= temp_max
            writeDigitalPin(arduino_obj, green_led_pin, 1);
            writeDigitalPin(arduino_obj, yellow_led_pin, 0);
            writeDigitalPin(arduino_obj, red_led_pin, 0);
            status_str = 'Comfort, Green ON';
        
        elseif current_temp < temp_min
            writeDigitalPin(arduino_obj, red_led_pin, 0);
            time_since_yellow = seconds(datetime('now') - last_yellow_toggle);
            if time_since_yellow >= yellow_blink_period
                yellow_led_state = ~yellow_led_state;
                writeDigitalPin(arduino_obj, yellow_led_pin, yellow_led_state);
                last_yellow_toggle = datetime('now');
            end
            status_str = 'Low Temp, Yellow Blink';
        
        else
            writeDigitalPin(arduino_obj, yellow_led_pin, 0);
            time_since_red = seconds(datetime('now') - last_red_toggle);
            if time_since_red >= red_blink_period
                red_led_state = ~red_led_state;
                writeDigitalPin(arduino_obj, red_led_pin, red_led_state);
                last_red_toggle = datetime('now');
            end
            status_str = 'High Temp, Red Blink';
        end
        
        % Print to console
        fprintf('%.1f\t%.2f\t\t%s\n', current_runtime, current_temp, status_str);
        
        % 5. Maintain Sampling Interval
        pause(sample_interval);
    end
catch ME
    % Cleanup on Ctrl+C
    fprintf('\n===== MONITORING STOPPED =====\n');
    writeDigitalPin(arduino_obj, green_led_pin, 0);
    writeDigitalPin(arduino_obj, yellow_led_pin, 0);
    writeDigitalPin(arduino_obj, red_led_pin, 0);
    if ishandle(gcf)
        close(gcf);
    end
    fprintf('Cleanup complete.\n');
end

end