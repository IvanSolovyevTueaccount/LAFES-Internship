%data = read_rls_log("E201_COM3.LOG");

% plot(data.Timestamp, data.Value);
% xlabel("Time");
% ylabel("Measurement");
% grid on;

ts = read_rls_log_timeseries("E201_COM3.LOG");
save("rls_data.mat", "ts");

function ts = read_rls_log_timeseries(filename)

    opts = delimitedTextImportOptions("Delimiter",";", "NumVariables",4);
    opts.VariableNames = ["Port", "Date", "Time", "Value"];
    opts.VariableTypes = ["string", "string", "string", "double"];
    opts.ExtraColumnsRule = "ignore";
    opts.EmptyLineRule = "read";
    opts.ConsecutiveDelimitersRule = "join";

    T = readtable(filename, opts);

    % Remove rows where Value is NaN
    T = T(~isnan(T.Value), :);
    values = T.Value;

    % Create a simple time vector starting at 0, increment by 1
    time_numeric = 0:(length(values)-1);

    % Create timeseries
    ts = timeseries(values, time_numeric);
    ts.TimeInfo.Units = 'seconds';  % or 'arbitrary units'

end
