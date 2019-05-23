function output = normalize(input, ymin, ymax)
xmax = max(max(input));
xmin = min(min(input));
output = (ymax - ymin) * (input - xmin) / (xmax - xmin) + ymin;
end