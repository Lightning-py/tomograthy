leftbottom = [0, 0]  # координаты нижней левой точки сетки
dx = 1  # длина элемента по x
dy = 1  # длина элемента по y
numx = 20  # количество сегментов по x
numy = 20  # количество сегментов по y

m = numx * numy;
n = size(sources_coords, 1);


function idx = get_cell(x, y, numx, numy, dx, dy)
    i = floor(x / dx) + 1;
    j = floor(y / dy) + 1;
    if i < 1 || i > numx || j < 1 || j > numy
        idx = -1;
    else
        idx = (j - 1) * numx + i;
    end
end


A_mat = zeros(n, m);

for k = 1:n
    x0 = sources_coords(k,1);
    y0 = sources_coords(k,2);
    vx = sources_vectors(k,1);
    vy = sources_vectors(k,2);


    vnorm = sqrt(vx^2 + vy^2);
    vx = vx / vnorm; vy = vy / vnorm;


    max_len = sqrt((numx * dx)^2 + (numy * dy)^2) + 2 * sqrt(dx ^ 2 + dy ^ 2);
    dt = 0.01;    % шаг движения вдоль луча

    t = 0;
    while t < max_len
        x = x0 + vx * t;
        y = y0 + vy * t;
        idx = get_cell(x, y, numx, numy, dx, dy);
        if idx > 0
            A_mat(k, idx) = A_mat(k, idx) + dt;
        end
        t = t + dt;
    end
end


% Нормировка по строкам (длина каждого луча)
row_norms = sqrt(sum(A_mat.^2, 2));
row_norms(row_norms < EPS) = 1;
A_row_norm = A_mat ./ row_norms;
b_norm = reciever_data ./ row_norms;

% Нормировка по столбцам
col_norms = sqrt(sum(A_row_norm.^2, 1));
col_norms(col_norms < EPS) = 1;
A_full_norm = A_row_norm ./ col_norms;


lambda = 1e-4


% Решение
%x_norm = (A_full_norm' * A_full_norm + lambda * eye(m)) \ (A_full_norm' * b_norm);

% Возвращаем масштаб
%x = x_norm ./ col_norms';


printf("решаю матрицу\n")
x = linsolve(A_mat, reciever_data);

solution = reshape(x, numx, numy)';

disp('Решение:')
format long g
disp(solution)

plot_matrix_with_numbers(solution)

