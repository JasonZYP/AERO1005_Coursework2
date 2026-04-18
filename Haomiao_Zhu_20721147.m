%MATLAB Coursework 2
%Name: Haomiao Zhu
%Email Address: ssyhz38@nottingham.edu.cn
%Student ID: 20721147


%% PRELIMINARY TASK - ARDUINO AND GIT INSTALLATION [5 MARKS]
% (a) GitHub
!git --version
% Initial commit, add coursework templates.
% https://github.com/JasonZYP/AERO1005_Coursework2.git

% (b) MATLAB/Arduino configuration
% I have already downloaded the "MATLAB Support Package for Arduino
% Hardware".

% (c) Arduino communication
% 1. Initialise Arduino connection
a = arduino('COM7','UNO'); 

% 2. Define parameters
led_pin = 'D13';
blink_interval = 0.5;
loop_times = 10;

% 3. Blink loop
fprintf('Starting LED blink test\n');
for i = 1:loop_times
    % Turn LED ON
    writeDigitalPin(a, led_pin, 1); 
    fprintf('Loop %d: LED ON\n',i);
    pause(blink_interval);
   
    % Turn LED OFF
    writeDigitalPin(a, led_pin, 0);  
    fprintf('Loop %d: LED OFF\n',i);
    pause(blink_interval);
end
fprintf('LED blink test completed successfully\n');

% Release Arduino port
clear a;

%% TASK 1 - READ TEMPERATURE DATA, PLOT, AND WRITE TO A LOG FILE [20 MARKS]

% (a) I have finished the sensor wiring and connecting and took a clear
% photo of the completed wiring, insert it into my Word template.


%% (b) Initialise Parameters
a = arduino('COM7','UNO');
% Acquisition parameters
duration = 600;               % Total acquisition time (seconds) = 10 minutes
sample_interval = 1;          % Sampling interval (seconds)
total_samples = duration / sample_interval;
% Sensor parameters
temp_sensor_pin = 'A0';
V0 = 0.5;                      % Voltage at 0°C (V)
TC = 0.01;                     % Temperature coefficient (V/°C)
% Pre-allocate arrays for efficiency
time_array = zeros(1, total_samples);
voltage_array = zeros(1, total_samples);
temperature_array = zeros(1, total_samples);

%% Loop to Acquire Temperature Data
fprintf('===== TEMPERATURE DATA ACQUISITION STARTED =====\n');
fprintf('Acquisition Duration: %d seconds | Sampling Interval: %d second\n', duration, sample_interval);
fprintf('Estimated Completion Time: %s\n', datestr(datetime('now') + seconds(duration)));

for sample_idx = 1:total_samples
    % Record sample time
    time_array(sample_idx) = (sample_idx - 1) * sample_interval;
    % Read voltage from analog pin
    voltage_array(sample_idx) = readVoltage(a, temp_sensor_pin);
    % Convert voltage to temperature (°C)
    temperature_array(sample_idx) = (voltage_array(sample_idx) - V0) / TC;
    % Print progress to console
    fprintf('Sample Progress: %d/%d | Time: %ds | Temperature: %.2f°C\n',...
        sample_idx, total_samples, time_array(sample_idx), temperature_array(sample_idx));
    % Maintain sampling interval
    pause(sample_interval);
end

fprintf('===== TEMPERATURE DATA ACQUISITION COMPLETED =====\n');

% Calculate statistical values
max_temp = max(temperature_array);
min_temp = min(temperature_array);
avg_temp = mean(temperature_array);

% Print statistical results
fprintf('Statistical Results:\n');
fprintf('Maximum Temperature: %.2f°C\n', max_temp);
fprintf('Minimum Temperature: %.2f°C\n', min_temp);
fprintf('Average Temperature: %.2f°C\n', avg_temp);


%% (c) Plot Temperature vs Time Curve
figure('Name','Capsule Temperature Acquisition Curve');
plot(time_array, temperature_array, 'b-', 'LineWidth', 1.5);
grid on;
xlabel('Time (s)', 'FontSize', 12);
ylabel('Temperature (°C)', 'FontSize', 12);
title('10-Minute Temperature Monitoring Curve for Sub-Orbital Capsule', 'FontSize', 14);
% Save plot image
saveas(gcf, 'temperature_curve.png');
fprintf('Temperature curve saved as temperature_curve.png\n');
% I have inserted this image into Task 1 c) of my Word template

%% (d) Formatted Output to Console (Per Assessment Specification)
current_date = datestr(datetime('now'), 'mm/dd/yyyy');
location = ' The University of Nottingham Ningbo China'; 

% Print header
fprintf('\n');
fprintf('Data logging initiated - %s Location - %s\n', current_date, location);
fprintf('\n');

% Print minute-by-minute temperature (0-10 minutes)
for minute = 0:10
    sample_point = minute * 60 + 1;
    if sample_point > total_samples
        sample_point = total_samples;
    end
    current_temp = temperature_array(sample_point);
    fprintf('Minute\t%d\n', minute);
    fprintf('Temperature\t%.2f C\n', current_temp);
    fprintf('\n');
end

% Print statistical values
fprintf('Max temp\t%.2f C\n', max_temp);
fprintf('Min temp\t%.2f C\n', min_temp);
fprintf('Average temp\t%.2f C\n', avg_temp);
fprintf('Data logging terminated\n');

%% (d) Write Data to Log File
file_id = fopen('capsule_temperature.txt', 'w');
if file_id == -1
    error('Failed to open log file, check folder permissions!');
end

% Write formatted content to file
fprintf(file_id, 'Data logging initiated - %s Location - %s\n', current_date, location);
fprintf(file_id, '\n');
for minute = 0:10
    sample_point = minute * 60 + 1;
    if sample_point > total_samples
        sample_point = total_samples;
    end
    current_temp = temperature_array(sample_point);
    fprintf(file_id, 'Minute\t%d\n', minute);
    fprintf(file_id, 'Temperature\t%.2f C\n', current_temp);
    fprintf(file_id, '\n');
end
fprintf(file_id, 'Max temp\t%.2f C\n', max_temp);
fprintf(file_id, 'Min temp\t%.2f C\n', min_temp);
fprintf(file_id, 'Average temp\t%.2f C\n', avg_temp);
fprintf(file_id, 'Data logging terminated\n');

% Critical: Close the file to save content
fclose(file_id);
fprintf('Log file saved as capsule_temperature.txt\n');

% Release Arduino port
clear a;

%% TASK 2 - LED TEMPERATURE MONITORING DEVICE IMPLEMENTATION [25 MARKS]

% Initialise Arduino connection
a = arduino('COM7','UNO');

% Call monitoring function (Press Ctrl+C to stop execution)
temp_monitor(a);

% Release Arduino port
clear a;

% I write some short documentation to be included in my function, which can be retrieved
% using the command 'doc temp_monitor' and briefly explains the function use and purpose.
% I put the images of the device and the plot and the flow charts into my
% Word document. Github is really hard to connect, I finished it on
% 17/4/2026 but i spent an hour to try to send it to Github and I fail.

%% TASK 3 - ALGORITHMS – TEMPERATURE PREDICTION [30 MARKS]

% Initialise Arduino connection
a = arduino('COM7','UNO');

% Call prediction function (Press Ctrl+C to stop execution)
temp_prediction(a);

% Release Arduino port
clear a;

% I write some short documentation to be included in my function, which can be retrieved
% using the command 'doc temp_prediction' and briefly explains the function use and purpose.
% I put the flow chart into my Word document.

%% TASK 4 - REFLECTIVE STATEMENT [5 MARKS]

% In this project, I built a temperature monitoring and warning system for a suborbital capsule using MATLAB and an Arduino. 
% The system handles real-time temperature collection, live monitoring, rate-of-change prediction, and graded alerts. 
% I also used Github for version control throughout.

% The biggest challenge as a MATLAB beginner was quickly getting up to speed with hardware communication, function design, 
% live plotting, and timing control. A particular headache was the conflict between LED blinking and sampling timing — 
% I fixed it by splitting the timestamp logic so that pause wouldn't mess up the sampling accuracy. On the plus side, 
% my code is well commented and logically organized. A simple moving average helped smooth out sensor noise, and I stuck closely to the project specs.

% That said, the system does have its limits. The temperature prediction is based on a simple linear model, 
% so it doesn't handle non-linear environmental changes well. Hardware noise immunity could also be better. 
% In the future, I'd like to try a Kalman filter for smoother data, use a non-linear model to improve predictions, 
% and add multiple sensors for redundancy and higher reliability.

% Overall, this project taught me how to approach real engineering problems with code, and really boosted my skills in combining software with hardware.