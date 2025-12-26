function result = check_end(x, y, x_dest, y_dest, up, right)
    result = 0
    if (up && y >= y_dest || !up && y <= y_dest)
      result = 1;
    endif
    if (right && x >= x_dest || !right && x <= x_dest)
      result = 1;
    endif
endfunction

