function y = movcustom(x, k, interval, func)
    %MOVRMS calculate a moving RMS on a vector x with a window size of k
    %   Similar to the function movmean
    interval = interval / 10;
    k = k / 10;
    y = zeros(floor(length(x)/interval), 1);
    output_index = 1;
    for start_index = 1:interval:length(x)
        end_index = start_index + k;
        if end_index > length(x)
            end_index = length(x);
        end
        window = x(start_index:end_index);
        y(output_index) = func(window);
        output_index = output_index + 1;
    end
end
