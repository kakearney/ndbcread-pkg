function data = fixedwidthread(str, colwidth, isnum, fastflag)
%FIXEDWIDTHREAD Reads data from a character array with fixed width columns
%
% data = fixedwidthread(str, colwidth, isnum)
% data = fixedwidthread(str, colwidth, isnum, fastflag)
%
% This colun separates a character array into a cell array, where columns
% are a fixed number of characters.  
%
% Input variables:
%
%   str:        n x m 1d or 2d character array
%
%   colwidth:   vector holding number of character in each column
%
%   isnum:      logical vector the same length as colwidth indicating
%               whether the data in each column is numeric.  If true, the
%               data will be converted to double; otherwise it will be left
%               as a string
%
%   fastflag:   logical scalar, if true a the conversion from string to
%               double is a little faster, but can only be used if numeric
%               columns have no empty cells and no imaginary numbers.
%
% Output variables:
%
%   data:       n x ncol cell array holding data separated into columns

% Copyright 2008 Kelly Kearney


if ~(isvector(colwidth) && isnumeric(colwidth))
    error('Column width must be a numeric vector');
end

if ~(isvector(isnum) && islogical(isnum) && isequal(length(isnum), length(colwidth)))
    error('isnum must be a logical vector the same length as colwidth');
end

if nargin == 3
    fastflag = false;
end

nrow = size(str,1);
ncol = length(colwidth);

colwidth = reshape(colwidth, 1, []);

colstart = 1 + [0 cumsum(colwidth)];
colend = colstart(2:end) - 1;
colstart = colstart(1:end-1);

data = cell(nrow, ncol);

for icol = 1:ncol
    temp = cellstr(str(:,colstart(icol):colend(icol)));
    if isnum(icol)
        if fastflag
            temp = cellfun(@(x) sscanf(x, '%f',1), temp, 'uni', 0);
        else
            temp = cellfun(@str2num, temp, 'uni', 0);
        end
    end
    data(:,icol) = temp;
end



