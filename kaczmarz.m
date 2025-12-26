function [x, errors, residuals] = kaczmarz(A, b, x0, max_iter, lambda, tol)
    % Метод Качмажа
    % Вход:
    %   A - матрица m×n
    %   b - вектор правой части m×1
    %   x0 - начальное приближение (по умолчанию нулевое)
    %   max_iter - максимальное число итераций (по умолчанию 1000)
    %   lambda - параметр релаксации (0 < lambda < 2, по умолчанию 1)
    %   tol - критерий остановки (по умолчанию 1e-6)
    % Выход:
    %   x - решение
    %   errors - история ошибок
    %   residuals - история невязок

    % Параметры по умолчанию
    if nargin < 3 || isempty(x0)
        x0 = zeros(size(A, 2), 1);
    end
    if nargin < 4 || isempty(max_iter)
        max_iter = 1000;
    end
    if nargin < 5 || isempty(lambda)
        lambda = 1.0;  % Без релаксации
    end
    if nargin < 6 || isempty(tol)
        tol = 1e-6;
    end

    % Проверка параметров
    if lambda <= 0 || lambda >= 2
        error('Параметр релаксации lambda должен быть в (0, 2)');
    end

    [m, n] = size(A);
    x = x0;

    % Предварительные вычисления (для ускорения)
    norms_squared = sum(A.^2, 2);  % ||a_i||^2

    % Инициализация истории
    errors = zeros(max_iter, 1);
    residuals = zeros(max_iter, 1);

    % Основной цикл
    for k = 1:max_iter
        % Циклический выбор уравнения
        i = mod(k-1, m) + 1;

        % Текущая строка
        a_i = A(i, :);
        b_i = b(i);

        % Вычисление невязки для этого уравнения
        r_i = b_i - a_i * x;

        % Обновление решения
        if norms_squared(i) > 0
            x = x + (lambda * r_i / norms_squared(i)) * a_i';
        end

        % Сохранение истории
        residuals(k) = norm(A*x - b);

        % Критерий остановки
        if residuals(k) < tol
            fprintf('Сходимость достигнута на итерации %d\n', k);
            errors = errors(1:k);
            residuals = residuals(1:k);
            return;
        end

        % Вывод прогресса каждые 100 итераций
        if mod(k, 100) == 0
            fprintf('Итерация %d, невязка: %e\n', k, residuals(k));
        end
    end

    warning('Достигнуто максимальное число итераций (%d)', max_iter);
end
