function exportSearsHaackTXT(geometry, filename)

    if nargin < 2
        filename = 'SearsHaackProfile.txt';
    end

    fid = fopen(filename,'w');

    if fid == -1
        error('Could not create %s', filename);
    end

    % X  Y  Z (tab separated)
    for i = 1:length(geometry.x)
        fprintf(fid,'%.10f\t%.10f\t0.0000000000\n', ...
            geometry.x(i), geometry.radius(i));
    end

    fclose(fid);

    fprintf('SolidWorks TXT file created:\n%s\n', filename);

end