function generate_rotating_tomography_data(material_matrix, initial_angle = 0, angle_step)
  % Генератор данных для вращающейся системы компьютерной томографии
  % material_matrix - матрица numy x numx с коэффициентами от 0 до 1
  % initial_angle - начальный угол (градусы)
  % angle_step - шаг вращения (градусы)

  % Параметры сетки
  leftbottom = [0, 0];
  dx = 1;
  dy = 1;
  numy = size(material_matrix, 1);  % количество строк в матрице материала
  numx = size(material_matrix, 2);  % количество столбцов в матрице материала
  m = numx * numy;  % общее количество элементов

  % Центр вращения (центр сетки)
  center_x = leftbottom(1) + numx * dx / 2;
  center_y = leftbottom(2) + numy * dy / 2;
  C = [center_x, center_y];

  % Исходные положения источников (вертикальная доска слева от сетки)
  % numy источников с шагом 1 по y, начиная от нижнего края сетки
  initial_sources = zeros(numy, 2);
  initial_vectors = zeros(numy, 2);

  for i = 1:numy
    % Положения источников: x = -0.5, y от 0.5 до numy-0.5 с шагом 1
    y_pos = leftbottom(2) + (i - 0.5) * dy;
    initial_sources(i, :) = [-0.5, y_pos];
    initial_vectors(i, :) = [1, 0];  % первоначально направлены горизонтально вправо
  end

  % Подготовка для сбора всех данных
  all_sources_coords = [];
  all_sources_vectors = [];
  all_reciever_data = [];



  % Главный цикл: поворачиваем систему и собираем данные
  current_angle = initial_angle;
  max_angle = 360;  % максимальный угол поворота

  % Счетчик общего количества источников
  total_sources = 0;

  while current_angle <= initial_angle + max_angle + angle_step/2

    % Поворачиваем источники и векторы
    rotated_sources = zeros(numy, 2);
    rotated_vectors = zeros(numy, 2);

    for i = 1:numy
      rotated_sources(i, :) = rotate_point(initial_sources(i, :), current_angle, C);
      rotated_vectors(i, :) = rotate_vector(initial_vectors(i, :), current_angle);
    endfor

    % Рассчитываем данные томографии
    [A_mat, rec_data] = calculate_tomography(rotated_sources, rotated_vectors, numx, numy, dx, dy, m, leftbottom, material_matrix);

    % Добавляем к общим массивам
    all_sources_coords = [all_sources_coords; rotated_sources];
    all_sources_vectors = [all_sources_vectors; rotated_vectors];
    all_reciever_data = [all_reciever_data; rec_data];

    total_sources += numy;


    % Увеличиваем угол
    current_angle += angle_step;
  endwhile

  % Выводим итоговые данные в формате для программы томографии
  n = total_sources;

  printf("m = %d  # количество делений сетки\n", m);
  printf("n = %d  # общее количество лучей (источников)\n\n", n);

  printf("EPS = 1e-5\n\n");

  printf("sources_coords = [  # координаты источников\n");
  for i = 1:n
    printf("  [%.6f, %.6f]", all_sources_coords(i, 1), all_sources_coords(i, 2));
    if i < n
      printf(",\n");
    else
      printf("\n");
    endif
  endfor
  printf("]\n\n");

  printf("sources_vectors = [  # вектора излучения источников\n");
  for i = 1:n
    printf("  [%.6f, %.6f]", all_sources_vectors(i, 1), all_sources_vectors(i, 2));
    if i < n
      printf(",\n");
    else
      printf("\n");
    endif
  endfor
  printf("]\n\n");

  printf("reciever_data = [\n");
  for i = 1:n
    printf("  %.6f", all_reciever_data(i));
    if i < n
      printf(";\n");
    else
      printf("\n");
    endif
  endfor
  printf("]\n\n");

  printf("leftbottom = [0, 0]  # координаты нижней левой точки сетки\n");
  printf("dx = 1  # длина элемента по x\n");
  printf("dy = 1  # длина элемента по y\n");
  printf("numx = %d  # количество сегментов по x\n", numx);
  printf("numy = %d  # количество сегментов по y\n\n", numy);

  % Визуализация (опционально)
  visualize = false;
  if visualize
    figure;
    hold on;

    % Рисуем сетку
    for i = 0:numx
      plot([leftbottom(1) + i*dx, leftbottom(1) + i*dx], ...
           [leftbottom(2), leftbottom(2) + numy*dy], 'k-', 'LineWidth', 0.5);
    endfor
    for i = 0:numy
      plot([leftbottom(1), leftbottom(1) + numx*dx], ...
           [leftbottom(2) + i*dy, leftbottom(2) + i*dy], 'k-', 'LineWidth', 0.5);
    endfor

    % Рисуем источники и лучи для нескольких углов
    colors = {'r', 'g', 'b', 'm', 'c', 'y'};
    color_idx = 1;

    for angle_idx = 1:min(6, length(initial_angle:angle_step:initial_angle+max_angle))
      angle = initial_angle + (angle_idx-1)*angle_step;
      idx_start = (angle_idx-1)*numy + 1;
      idx_end = angle_idx*numy;

      if idx_end <= n
        color = colors{mod(color_idx-1, length(colors)) + 1};

        % Источники
        scatter(all_sources_coords(idx_start:idx_end, 1),
                all_sources_coords(idx_start:idx_end, 2),
                50, color, 'filled');

        % Лучи (короткие отрезки для визуализации направления)
        for i = idx_start:idx_end
          quiver(all_sources_coords(i, 1), all_sources_coords(i, 2),
                 all_sources_vectors(i, 1), all_sources_vectors(i, 2),
                 0.5, color, 'LineWidth', 1.5);
        endfor

        color_idx += 1;
      endif
    endfor

    % Центр вращения
    plot(C(1), C(2), 'ko', 'MarkerSize', 10, 'MarkerFaceColor', 'k');

    axis equal;
    grid on;
    title('Вращающаяся система томографии');
    xlabel('X');
    ylabel('Y');
    legend('Сетка', 'Источники 0°', 'Лучи 0°', 'Источники 20°', 'Лучи 20°', ...
           'Источники 40°', 'Лучи 40°', 'Центр вращения', ...
           'Location', 'bestoutside');
  endif

endfunction

  % Функция поворота точки вокруг центра
function rotated_point = rotate_point(point, angle_deg, center)
    angle_rad = deg2rad(angle_deg);
    x_rel = point(1) - center(1);
    y_rel = point(2) - center(2);

    x_rot = x_rel * cos(angle_rad) - y_rel * sin(angle_rad);
    y_rot = x_rel * sin(angle_rad) + y_rel * cos(angle_rad);

    rotated_point = [x_rot + center(1), y_rot + center(2)];
endfunction

  % Функция поворота вектора (без учета центра)
function rotated_vector = rotate_vector(vector, angle_deg)
  angle_rad = deg2rad(angle_deg);
  rotated_vector = [
    vector(1) * cos(angle_rad) - vector(2) * sin(angle_rad),
    vector(1) * sin(angle_rad) + vector(2) * cos(angle_rad)
  ];
endfunction

function [A_mat, rec_data] = calculate_tomography(sources_coords, sources_vectors, numx, numy, dx, dy, m, leftbottom, material_matrix)
    n_sources = size(sources_coords, 1);
    A_mat = zeros(n_sources, m);

    % Преобразуем материал в вектор
    material_vector = reshape(material_matrix', m, 1);

    for i = 1:n_sources
        x0 = sources_coords(i, 1);
        y0 = sources_coords(i, 2);
        vx = sources_vectors(i, 1);
        vy = sources_vectors(i, 2);

        % Если луч нулевой — пропускаем
        if vx == 0 && vy == 0
            continue;
        end

        % Индексы ячейки, в которой начинается луч
        ix = floor((x0 - leftbottom(1)) / dx) + 1;
        iy = floor((y0 - leftbottom(2)) / dy) + 1;

        % Ограничение по границам сетки
        ix = max(1, min(numx, ix));
        iy = max(1, min(numy, iy));

        % Шаги по осям
        if vx > 0
            stepX = 1;
            tMaxX = ((leftbottom(1) + ix*dx) - x0) / vx;
        elseif vx < 0
            stepX = -1;
            tMaxX = ((leftbottom(1) + (ix-1)*dx) - x0) / vx;
        else
            stepX = 0;
            tMaxX = inf;
        end

        if vy > 0
            stepY = 1;
            tMaxY = ((leftbottom(2) + iy*dy) - y0) / vy;
        elseif vy < 0
            stepY = -1;
            tMaxY = ((leftbottom(2) + (iy-1)*dy) - y0) / vy;
        else
            stepY = 0;
            tMaxY = inf;
        end

        tDeltaX = (stepX * dx) / vx;
        if vx == 0, tDeltaX = inf; end
        tDeltaY = (stepY * dy) / vy;
        if vy == 0, tDeltaY = inf; end

        % Переменные для текущей позиции луча
        t = 0;
        t_end = 1e6; % Большое значение для выхода за сетку

        while ix >= 1 && ix <= numx && iy >= 1 && iy <= numy
            % Индекс элемента в A_mat
            elem = (iy-1)*numx + ix;

            % Определяем длину пересечения с текущей ячейкой
            if tMaxX < tMaxY
                dt = tMaxX - t;
                t = tMaxX;
                tMaxX = tMaxX + tDeltaX;
                ix = ix + stepX;
            else
                dt = tMaxY - t;
                t = tMaxY;
                tMaxY = tMaxY + tDeltaY;
                iy = iy + stepY;
            end

            % Добавляем длину сегмента к элементу матрицы
            if elem >= 1 && elem <= m
                A_mat(i, elem) = A_mat(i, elem) + dt * sqrt(vx^2 + vy^2);
            end
        end
    end

    % Вычисляем данные с приемников
    rec_data = A_mat * material_vector;
end
