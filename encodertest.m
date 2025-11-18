data = read_rls_log("E201_COM3.LOG");

plot(data.Timestamp, data.Value);
xlabel("Time");
ylabel("Measurement");
grid on;


function data = read_rls_log(filename)
    % Reads RLS-style semicolon log:
    % COM3;DD.MM.YYYY;HH:MM:SS;VALUE

    % Read as text
    opts = delimitedTextImportOptions("Delimiter",";", ...
                                      "NumVariables",4, ...
                                      "ConsecutiveDelimitersRule","join");

    opts.VariableNames = ["Port", "Date", "Time", "Value"];
    opts.VariableTypes = ["string", "string", "string", "double"];

    T = readtable(filename, opts);

    % Combine date + time into MATLAB datetime
    T.Timestamp = datetime(strcat(T.Date, " ", T.Time), ...
                           'InputFormat','dd.MM.yyyy HH:mm:ss');

    % Sort just in case
    T = sortrows(T, "Timestamp");

    % Reorder columns
    data = T(:, ["Timestamp", "Value", "Port"]);

    % Show first few lines
    disp(head(data));
end
