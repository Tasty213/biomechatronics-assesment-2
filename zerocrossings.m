function crossings = zerocrossings(x)
    previous = x(1);
    crossings = 0;
    for index = 2:length(x)
        current = x(index);
        if previous > 0 && current < 0
            crossings = crossings + 1;
        elseif previous < 0 && current > 0
            crossings = crossings + 1;
        end
    end
end