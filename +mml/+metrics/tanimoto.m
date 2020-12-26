function sim = tanimoto(x, y)
    assert(isequal(size(x),size(y)), "x and y must have the same shape");
    sim = sum(x&y) / sum(x|y);
end