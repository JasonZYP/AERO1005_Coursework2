% ==================== temp_prediction.m Temperature Prediction Function ====================
% TEMP_PREDICTION Temperature rate of change calculation and 5-minute prediction function
% Usage: temp_prediction(arduino_obj)
% Input Parameters: arduino_obj - Initialised Arduino object from the main script
% Functionality:
%   1. Acquire temperature every 1 second, calculate smoothed rate of change with moving average
%   2. Linear prediction of temperature in 5 minutes, formatted data printout
%   3. LED control per rate of change: >4°C/min heating red ON, >4°C/min cooling yellow ON, stable green ON
% Author: Haomiao Zhu 20721147
% Version: 1.0
% Date: 18/4/2026
function temp_prediction(arduino_obj)

%% 1. Input Parameter Validation
if nargin < 1
    error('Please pass an initialised Arduino object! Usage: temp_prediction(a)');
end
if ~isvalid(arduino_obj)
    error('Invalid Arduino object! Initialise the object in the main script first.');
end

%% 2. Pin and Parameter Definition
% Sensor parameters
temp_sensor_pin = 'A0';
V0 = 0.5;
TC = 0.01;
% LED Pins (same as Task 2, no wiring changes needed)
green_led_pin = 'D2';
yellow_led_pin = 'D3';
red_led_pin = 'D4';
% Algorithm Parameters
sample_interval = 1;
smooth_window = 5;       % Moving average window for noise reduction
rate_threshold = 4;       % Rate of change threshold (°C/min)
prediction_time = 5*60;   % Prediction horizon: 5 minutes = 300 seconds
% Comfort Temperature Range
temp_min = 18;
temp_max = 24;

%% 3. Initialise Data Arrays
time_data = [];
temp_data = [];
rate_data = [];

%% 4. Initialise LEDs (All OFF)
writeDigitalPin(arduino_obj, green_led_pin, 0);
writeDigitalPin(arduino_obj, yellow_led_pin, 0);
writeDigitalPin(arduino_obj, red_led_pin, 0);

%% 5. Infinite Loop for Calculation & Prediction
fprintf('===== TEMPERATURE RATE MONITORING & PREDICTION STARTED =====\n');
fprintf('Rate Threshold: ±%.1f°C/min | Prediction Horizon: %d minutes\n', rate_threshold, prediction_time/60);
fprintf('Press Ctrl+C to stop execution\n');
fprintf('-------------------------------------------------------------------------\n');
fprintf('Time(s)\tCurrent Temp(°C)\tRate(°C/min)\t5min Predicted Temp(°C)\tStatus\n');
fprintf('-------------------------------------------------------------------------\n');

start_time = datetime('now');

while true
    % 1. Acquire Temperature
    current_runtime = seconds(datetime('now') - start_time);
    current_voltage = readVoltage(arduino_obj, temp_sensor_pin);
    current_temp = (current_voltage - V0) / TC;
    
    % Update data arrays
    time_data = [time_data, current_runtime];
    temp_data = [temp_data, current_temp];
    
    % 2. Calculate Smoothed Temperature Rate of Change
    current_rate = 0;
    if length(temp_data) >= 2
        % Instantaneous rate of change
        instant_rate = (temp_data(end) - temp_data(end-1)) / sample_interval;
        rate_data = [rate_data, instant_rate];
        % Moving average smoothing
        if length(rate_data) >= smooth_window
            smoothed_rate = mean(rate_data(end-smooth_window+1:end));
        else
            smoothed_rate = mean(rate_data);
        end
        current_rate = smoothed_rate;
    end
    
    % Convert to °C per minute
    rate_per_min = current_rate * 60;
    
    % 3. 5-Minute Temperature Prediction
    predicted_temp = current_temp + current_rate * prediction_time;
    
    % 4. Status Determination & Formatted Printout
    if current_temp >= temp_min && current_temp <= temp_max && abs(rate_per_min) <= rate_threshold
        status = 'Stable Comfort, Green ON';
    elseif rate_per_min > rate_threshold
        status = 'Rapid Heating, Red ON';
    elseif rate_per_min < -rate_threshold
        status = 'Rapid Cooling, Yellow ON';
    else
        status = 'Comfort Range, Normal Rate';
    end
    
    fprintf('%.1f\t%.2f\t\t\t%.2f\t\t\t%.2f\t\t\t\t%s\n',...
        current_runtime, current_temp, rate_per_min, predicted_temp, status);
    
    % 5. LED Control Logic
    if current_temp >= temp_min && current_temp <= temp_max && abs(rate_per_min) <= rate_threshold
        writeDigitalPin(arduino_obj, green_led_pin, 1);
        writeDigitalPin(arduino_obj, yellow_led_pin, 0);
        writeDigitalPin(arduino_obj, red_led_pin, 0);
    elseif rate_per_min > rate_threshold
        writeDigitalPin(arduino_obj, green_led_pin, 0);
        writeDigitalPin(arduino_obj, yellow_led_pin, 0);
        writeDigitalPin(arduino_obj, red_led_pin, 1);
    elseif rate_per_min < -rate_threshold
        writeDigitalPin(arduino_obj, green_led_pin, 0);
        writeDigitalPin(arduino_obj, yellow_led_pin, 1);
        writeDigitalPin(arduino_obj, red_led_pin, 0);
    else
        writeDigitalPin(arduino_obj, green_led_pin, 1);
        writeDigitalPin(arduino_obj, yellow_led_pin, 0);
        writeDigitalPin(arduino_obj, red_led_pin, 0);
    end
    
    % 6. Maintain Sampling Interval
    pause(sample_interval);
end

% Turn off all LEDs when stopped
writeDigitalPin(arduino_obj, green_led_pin, 0);
writeDigitalPin(arduino_obj, yellow_led_pin, 0);
writeDigitalPin(arduino_obj, red_led_pin, 0);
fprintf('-------------------------------------------------------------------------\n');
fprintf('===== MONITORING & PREDICTION STOPPED =====\n');

end