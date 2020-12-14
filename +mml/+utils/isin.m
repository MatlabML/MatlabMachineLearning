function isin_ = isin(string, cellobj)
assert(ischar(string), 'the first input must be a cell');
assert(iscell(cellobj), 'the second input must be a cell');
isin_ = any(strcmp(string, cellobj));