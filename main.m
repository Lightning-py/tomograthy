
m = 25 # количество делений сетки
n = 18 # количество лучей (источников)


EPS=1e-5

sources_coords = [ # координаты источников в формате (x_i; y_i)
  [-0.5, 0.5], # 1
  [-0.5, 1.5],
  [-0.5, 2.5],
  [-0.5, 3.5],
  [-0.5, 4.5],
  [-0.5, 5.5],
  [-1.24264, 3.7011], # 2
  [-0.53553, 4.41421],
  [0.17157, 5.12132],
  [0.87868, 5.82843],
  [1.58579, 6.53553],
  [2.29289, 7.24264],
  [3.70711, 7.24264], # 3
  [4.41421, 6.53553],
  [5.12132, 5.82843],
  [5.82843, 5.12132],
  [6.53553, 4.41421],
  [7.24264, 3.70711],
]

sources_vectors = [ # вектора излучения источников
   [1, 0], # 1
   [1, 0],
   [1, 0],
   [1, 0],
   [1, 0],
   [1, 0],
   [0.707, -0.707], # 2
   [0.707, -0.707],
   [0.707, -0.707],
   [0.707, -0.707],
   [0.707, -0.707],
   [0.707, -0.707],
   [-0.707, -0.707], # 3
   [-0.707, -0.707],
   [-0.707, -0.707],
   [-0.707, -0.707],
   [-0.707, -0.707],
  # [-0.707, -0.707],
]

# reciever_coords - координаты приемников

reciever_data = [
  0;
  0;
  1;
  1;
  0;
  0;
  0; # 2
  1.24264;
  0;
  0;
  1.24264;
  0;
  0; # 3
  0;
  1;
  1;
  0;
  0;
]

leftbottom = [0, 0] # координаты нижней левой точки сетки
dx = 1 # длина элемента по x
dy = 1 # длина элемента по y

numx = 5 # количество сегментов по x
numy = 5 # количество сегментов по y

A_result = zeros(n, m) # матрица длин пересечений лучей с элементами

sources_equations = zeros(n, 3) # матрица коэффициентов уравнений прямых от лучей источников




# поиск длин пересечений элементов лучами и расстановка элементов в матрицу A
# 1. определяем направление движения прямой по прямым сетки (справа-налево/слева-направо по x, сверху-вниз/снизу-вверх по y)
# 2. через расстояние проверяем что встретим раньше, прямую по x или прямую по y
# 3. идентифицируем полученный четырехугольниик и ставим коэффициент в матрицу
# 4. по найденной оси переходим к следующей прямой, переходим к п.2


# уравнение прямой получается по формуле -Bx+Ay+(Bx_0-Ay_0)=0

# сборка матрицы
for i = 1:n
  # взяли очередной источник
  # координаты - sources_coords(i) - (x_0, y_0) и sources_vectors(i) - (A, B)

  prev_cross = [];
  cross = [];

  A = sources_vectors(i, 1)
  B = sources_vectors(i, 2)

  x_0 = sources_coords(i, 1)
  y_0 = sources_coords(i, 2)



  right = true
  up = true

  # определили направления движения по прямым сетки
  if A < 0
    right = false
  endif

  if B < 0
    up = false
  endif


  # определяем начальные положения в сетке
  # x_now и y_now это коэффициенты c1 и c2 в уравнениях x = c1; y = c2;
  x_now = 0;
  y_now = 0;

  # определяем конечные положения, при достижении которых должны остановить поиск точек пересечения
  x_dest = 0;
  y_dest = 0;

  # если идем вправо
  if right
    # ближайшая в сетке координата по x это максимум между ближайшей константой и самой левой нижней точкой в сетке
    # конец пути по x в таком случае равняется самой правой точкой в сетке
    x_now = max(x_0 / dx, leftbottom(1))
    x_dest = leftbottom(1) + numx * dx
  else
    # если идем налево

    # ближайшая в сетке координата по x это минимум между ближайшей константой справа и самой правой точкой сетки
    x_now = min(ceil(x_0 / dx), leftbottom(1) + numx * dx)
    x_dest = leftbottom(1)
  endif

  if up
    # если движемся вверх

    # ближайшая в сетке координата по y это максимум между
    y_now = max(y_0 / dy, leftbottom(2))
    y_dest = leftbottom(2) + numy * dy
  else
    y_now = min(y_0 / dy, leftbottom(2) + numy * dy)
    y_dest = leftbottom(2)
  endif

  xcoord = x_0;
  ycoord = y_0;

  # сколько прямых по x и по y прошли
  count_x = 0;
  count_y = 0;

  # пока по одной из осей не достигли конца сетки - идем
  while check_end(xcoord, ycoord, x_dest, y_dest, up, right) == 0
    # новая точка при обновлении по x
    x_new1 = x_now;
    y_new1 = (B * x_now + (A * y_0 - B * x_0)) / A;

    # новая точка при обновлении по y
    x_new2 = ((B * x_0 - A * y_0) + A * y_now) / B;
    y_new2 = y_now;

    if !isnan(y_new1)
      new1 = [x_new1 - xcoord, y_new1 - ycoord]
    else
      new1 = [inf, inf]
    endif

    if !isnan(x_new2)
      new2 = [x_new2 - xcoord, y_new2 - ycoord]
    else
      new2 = [inf, inf]
    endif

    new1sq = new1(1) ^ 2 + new1(2) ^ 2;
    new2sq = new2(1) ^ 2 + new2(2) ^ 2;

    if abs_equal(new1sq, new2sq, epsilon=EPS)
      # нормы векторов совпадают, значит мы попали на пересечение двух прямых, подтягиваем обе координаты
      printf("двигаем обе точки\n")

      count_x = count_x + 1;
      count_y = count_y + 1;

      xcoord = x_new1;
      ycoord = y_new1;

      if right
        x_now = x_now + dx;
      else
        x_now = x_now - dx;
      endif

      if up
        y_now = y_now + dy;
      else
        y_now = y_now - dy;
      endif
    elseif new1sq < new2sq
      # норма первого вектора меньше, значит он ближе, выбираем ось x
      printf("выбираем x\n")
      count_x = count_x + 1;
      xcoord = x_new1;
      ycoord = y_new1;

      if right
        x_now = x_now + dx;
      else
        x_now = x_now - dx;
      endif
    elseif new1sq > new2sq
      # норма второго вектора меньше, значит он ближе, выбираем ось y
      printf("выбираем y\n")
      count_y = count_y + 1;
      xcoord = x_new2;
      ycoord = y_new2;

      if up
        y_now = y_now + dy;
      else
        y_now = y_now - dy;
      endif
    endif
    cross = [xcoord, ycoord]

    if !isempty(prev_cross)
      lenght = norm([prev_cross(1) - cross(1), prev_cross(2) - cross(2)])
      element = get_num_element(prev_cross(1), prev_cross(2), cross(1), cross(2), numx, numy, dx, dy)

       if element > 25
         return
       endif

      A_result(i, element) = lenght
    endif
    prev_cross = cross;
  endwhile



end

solution = linsolve(A_result, reciever_data)
kach = kaczmarz(A_result, reciever_data, 0.5 * ones(m, 1) , 5000, 0.2, 1e-3)
kach = reshape(kach, numx, numy)

plot_matrix_with_numbers(kach);

