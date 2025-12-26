function plot_matrix_with_numbers(M)
    figure('Position', [100, 100, 800, 600]);

    imagesc(M);
    colormap(1 - gray(256));




    [m, n] = size(M);

    for i = 1:m
        for j = 1:n
            if M(i,j) > max(M(:))/2
                text_color = 'w';
            else
                text_color = 'k';
            end

            text(j, i, sprintf('%.4f', M(i,j)), ...
                 'HorizontalAlignment', 'center', ...
                 'VerticalAlignment', 'middle', ...
                 'Color', text_color, ...
                 'FontSize', 18, ...
                 'FontWeight', 'bold');
        end
    end

    axis equal tight;
    set(gca, 'XTick', 1:n, 'YTick', 1:m, ...
             'XTickLabel', {'Столбец 1', 'Столбец 2', 'Столбец 3'}, ...
             'YTickLabel', {'Строка 1', 'Строка 2', 'Строка 3'}, ...
             'FontSize', 15);


    grid on;
    set(gca, 'GridColor', 'k', 'GridAlpha', 0.3, 'LineWidth', 1.5);
end
