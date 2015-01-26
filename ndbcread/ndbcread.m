function A = ndbcread(file)
%NDBCREAD Reads National Data Buoy Center standard meteorological data file
%
% A = ndbcread(file)
%
% This function reads in the data from a National Data Buoy Center file of
% standard meteorological data (http://www.ndbc.noaa.gov).
%
% Input variables:
%
%   file:   name of file
%
% Output variables:
%
%   A:      1 x 1 structure with the following fields, each of which are n
%           x 1 arrays of data corresponding to the date field 
%
%           date:   date vector
%
%           wdir:   wind direction (deg clockwise from true north)
%
%           wspd:   wind speed (m/s)
%
%           gst:    peak gust speed (m/s)
%
%           wvht:   significant wave height (meters)
%
%           dpd:    dominant wave period (seconds) 
%
%           apd:    average wave period (seconds)
%
%           mwd:    mean wave direction corresponding to energy of the
%                   dominant period (degrees from true North)
%
%           pres:   sea level pressure (hPa).
%
%           atmp:   air temperature (Celsius)
%
%           wtmp:   sea surface temperature (Celsius). 
%
%           dewp:   dewpoint temperature taken at the same height as the
%                   air temperature measurement. 
%
%           vis:    station visibility (statute miles)
%
%           tide:   water level above or below Mean Lower Low Water (ft).

%------------------------
% Read in file as text
%------------------------

if ~exist(file, 'file')
    error('Cannot find file %s', file);
end

filetext = columndataread(file);

%------------------------
% Parse file
%------------------------

% Separate header from data

header = filetext(1,:);

has2 = regexpfound(filetext{2}, '[a-zA-Z]');
if has2
    data = filetext(3:end,:);
else
    data = filetext(2:end,:);
end

% Substitute NaN for empty strings

isemp = cellfun(@isempty, data);
if any(isemp(:))
    [data{isemp}] = deal('NaN');
end

% Check for misaligned headers

data = cellfun(@str2num, data, 'uni', false);
ncol = size(data,2);
ismulti = all(cellfun(@(x) ~isscalar(x), data));

temp = cell(0);
for icol = 1:ncol
    if ismulti(icol)
        temp = [temp regexp(header{icol}, '[a-zA-Z]*', 'match')];
    else
        temp = [temp header{icol}];
    end
end
header = cellfun(@strtrim, temp, 'uni', 0);

data = cell2mat(data);

% Substitute NaN for 99, 999

data(data == 99) = NaN;
data(data == 999) = NaN;

% Determine which column is which

datatypes = {...
    'year',  {'YY', 'YYYY', '#YY'}
    'month', {'MM'}
    'day',   {'DD'}
    'hour',  {'hh'}
    'min',   {'mm'}
    'wdir',  {'WD', 'WDIR'}
    'wspd',  {'WSPD'}
    'gust',  {'GST'}
    'wvht',  {'WVHT'}
    'dpd',   {'DPD'}
    'apd',   {'APD'}
    'mwd',   {'MWD'}
    'press', {'PRES', 'BAR'}
    'atmp',  {'ATMP'}
    'wtmp',  {'WTMP'}
    'dewp',  {'DEWP'}
    'vis',   {'VIS'}
    'tide',  {'TIDE'}
    };

for icol = 1:length(header)
    ismatch = cellfun(@(x) any(strcmp(header{icol}, x)), datatypes(:,2));
    if ~any(ismatch)
        error('Unknown column header: %s', header{icol});
    end
    idx = find(ismatch);
    A.(datatypes{idx}) = data(:,icol);
end
    




return

% OLD METHOD********************

fid = fopen(file, 'rt');
filetext = textscan(fid, '%s', 'delimiter', '\n');
fclose(fid);
filetext = filetext{1};

if strncmp('YYYY MM DD hh WD', filetext{1}, 16) || ...
   strncmp('YYYY MM DD hh  WD', filetext{1}, 17)
    type = 1;
elseif strncmp('#YY  MM DD hh mm', filetext{1}, 16)
    type = 2;
elseif strncmp('YYYY MM DD hh mm', filetext{1}, 16)
    type = 3;
elseif strncmp('YY MM DD hh WD', filetext{1}, 14)
    type = 4;
else
    error('File header does not match known headers');
end

%------------------------
% Parse columns
%------------------------

if type == 1
    data = strvcat(filetext{2:end});
    data = fixedwidthread(data, [4 3 3 3 4 6 4 6 6 6 4 7 6 6 6 5 6], true(1,17), true);
    data = cell2matfill(data, NaN);
    data(data == 99) = NaN;
    data(data == 999) = NaN;
    ndata = size(data,1);
    A.date = [data(:,1:4) zeros(ndata,2)];
    A.wdir = data(:,5);
    A.wspd = data(:,6);
    A.gst  = data(:,7);
    A.wvht = data(:,8);
    A.dpd  = data(:,9);
    A.apd  = data(:,10);
    A.mwd  = data(:,11);
    A.pres = data(:,12);
    A.atmp = data(:,13);
    A.wtmp = data(:,14);
    A.dewp = data(:,15);
    A.vis  = data(:,16);
    A.tide = data(:,17);
elseif type == 2
    data = strvcat(filetext{3:end});
    data = fixedwidthread(data, [4 3 3 3 3 4 6 4 6 6 6 4 7 6 6 6 5 6], true(1,18), true);
    data = cell2matfill(data, NaN);
    data(data == 99) = NaN;
    data(data == 999) = NaN;
    ndata = size(data,1);
    A.date = [data(:,1:5) zeros(ndata,1)];
    A.wdir = data(:,6);
    A.wspd = data(:,7);
    A.gst  = data(:,8);
    A.wvht = data(:,9);
    A.dpd  = data(:,10);
    A.apd  = data(:,11);
    A.mwd  = data(:,12);
    A.pres = data(:,13);
    A.atmp = data(:,14);
    A.wtmp = data(:,15);
    A.dewp = data(:,16);
    A.vis  = data(:,17);
    A.tide = data(:,18);
elseif type == 3
    data = strvcat(filetext{2:end});
    data = fixedwidthread(data, [4 3 3 3 3 4 6 4 6 6 6 4 7 6 6 6 5 6], true(1,18), true);
    data = cell2matfill(data, NaN);
    data(data == 99) = NaN;
    data(data == 999) = NaN;
    ndata = size(data,1);
    A.date = [data(:,1:5) zeros(ndata,1)];
    A.wdir = data(:,6);
    A.wspd = data(:,7);
    A.gst  = data(:,8);
    A.wvht = data(:,9);
    A.dpd  = data(:,10);
    A.apd  = data(:,11);
    A.mwd  = data(:,12);
    A.pres = data(:,13);
    A.atmp = data(:,14);
    A.wtmp = data(:,15);
    A.dewp = data(:,16);
    A.vis  = data(:,17);
    A.tide = data(:,18);
elseif type == 4
    data = strvcat(filetext{2:end});
    data = fixedwidthread(data, [2 3 3 3 4 6 4 6 6 6 4 7 6 6 6 5], true(1,16), true);
    data = cell2matfill(data, NaN);
    data(data == 99) = NaN;
    data(data == 999) = NaN;
    ndata = size(data,1);
    A.date = [data(:,1:4) zeros(ndata,2)];
    A.wdir = data(:,5);
    A.wspd = data(:,6);
    A.gst  = data(:,7);
    A.wvht = data(:,8);
    A.dpd  = data(:,9);
    A.apd  = data(:,10);
    A.mwd  = data(:,11);
    A.pres = data(:,12);
    A.atmp = data(:,13);
    A.wtmp = data(:,14);
    A.dewp = data(:,15);
    A.vis  = data(:,16);
end
