%MATLAB Coursework 2
%Name: Haomiao Zhu
%Email Address: ssyhz38@nottingham.edu.cn
%Student ID: 20721147


%% PRELIMINARY TASK - ARDUINO AND GIT INSTALLATION [5 MARKS]
% (a) GitHub
!git --version
% Initial commit, add coursework templates.

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

% Insert answers here

%% TASK 2 - LED TEMPERATURE MONITORING DEVICE IMPLEMENTATION [25 MARKS]

% Insert answers here


%% TASK 3 - ALGORITHMS – TEMPERATURE PREDICTION [30 MARKS]

% Insert answers here


%% TASK 4 - REFLECTIVE STATEMENT [5 MARKS]

% Insert answers here