function result = get_num_element(x1, y1, x2, y2, numx, numy, dx, dy)
  x = floor( ((x1 + x2) / 2) / dx ) + 1
  y = floor( ((y1 + y2) / 2) / dy ) + 1

  disp([x, y])

  result = max(0, y - 1) * numx + x
 endfunction
