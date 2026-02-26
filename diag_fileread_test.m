fprintf('pwd = %s\n', pwd);
fpath = 'recomoProto1-190-logs-acc-diff-speeds/0001_202602251145_0d2.csv';
fprintf('exists = %d\n', exist(fpath, 'file'));
fid = fopen(fpath, 'r');
fprintf('fid = %d\n', fid);
if fid > 0
    line1 = fgetl(fid);
    fprintf('header bytes: %d\n', numel(line1));
    line2 = fgetl(fid);
    fprintf('row1: %s\n', line2);
    line3 = fgetl(fid);
    fprintf('row2: %s\n', line3);
    fclose(fid);
    % Now try textscan with HeaderLines
    fid2 = fopen(fpath, 'r');
    raw = textscan(fid2, '%s%f%f%f%f', 'Delimiter', ',', 'HeaderLines', 1);
    fclose(fid2);
    fprintf('textscan nrows = %d\n', numel(raw{4}));
    if numel(raw{4}) >= 1
        fprintf('raw{4}(1) = %f\n', raw{4}(1));
    end
end
