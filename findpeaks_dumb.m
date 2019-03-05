function n = findpeaks_dumb(x, min_height, min_sharpness)
% Find peaks - dumb version. 
% TODO: replace with smarter version from signal processing toolbox, allow
% tweaking the parameters from the main program.
% n = findpeaks(x)
x(x < min_height) = 0;
n    = find(diff(diff(x) > min_sharpness) < 0);
u    = find(abs(x(n+1) - x(n)) > min_sharpness);
n(u) = n(u)+1;

end