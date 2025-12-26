function result = abs_equal(a, b, epsilon = 1e-10)
    result = abs(a - b) < epsilon;
endfunction

