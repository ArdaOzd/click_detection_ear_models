close all;

% Specify the directory containing the WAV files
folderPath = 'ScratchStimuliTest';  % Replace with your folder path

% List all WAV files in the folder
files = dir(fullfile(folderPath, '*.wav'));

% Define the specific X coordinates for the red line
x_start = 400.544;
x_end = 399.751;

% Loop through each file
for k = 1:length(files)
    % Full path to the file
    filePath = fullfile(files(k).folder, files(k).name);
    
    % Read the audio file
    [data, fs] = audioread(filePath);
    
    % Calculate the time vector for the current file in milliseconds
    t = (0:length(data)-1) / fs * 1000;  % Convert to milliseconds
    
    % Create a figure
    figure;
    
    % Plot the audio data
    plot(t, data, 'LineWidth', 4);
    hold on;
    
    % Find the indices for the specified X coordinates
    [~, idx_end] = min(abs(t - x_start));
    [~, idx_start] = min(abs(t - x_end));
    
    % Plot the line segment in red
    plot(t(idx_start:idx_end), data(idx_start:idx_end),  'LineWidth', 4);
    
    
    % Labels and title
    xlabel('Time (milliseconds)', 'FontSize', 36);
    ylabel('Amplitude', 'FontSize', 36);
    title('Waveform of a click in time domain', 'FontSize', 36);
    
    % Set the font size for the axes
    set(gca, 'FontSize', 36);
    
    % Show grid
    
    % Pause for 1 second
    pause(1);
    
    % Close the figure after the pause
    close;

    % Step 2: Compute the RMS value of the audio signal
    rms_value = sqrt(mean(data.^2));

    % Step 3: Convert the RMS value to SPL
    % Reference pressure in Pascals (20 µPa)
    ref_pressure = 20e-6;

    % SPL calculation
    SPL = 20 * log10(rms_value / ref_pressure);

    % Normalization
    Lref = 94; % Reference SPL in dB
    Lset = Lref + 20 * log10(sqrt(mean(data.^2)) * sqrt(2));
    normalized_signal = 2e-5 * 10^(Lset / 20) * data;

    plot(t, normalized_signal)
        pause(1);

    % Display the SPL
    fprintf('The Sound Pressure Level (SPL) of the original WAV file is: %.2f dB\n', SPL);
    fprintf('The signal has been normalized to an SPL of %.2f dB\n', Lref);
end
