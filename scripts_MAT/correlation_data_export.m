function correlation_data_export(grandavg_data, test, behaviour_data_folder, data_folder)
    % Compute neurophysiological differences
    fprintf('Computing power differences...\n');
    final_correlations = correlation_data_creation(grandavg_data);

    % Define behavioural comparison structure
    sheets = {"RET", "MAN"};
    comparisons_ret = {"ENC_RET", "RET_REC", "ENC_REC_RET"};
    comparisons_man = {"ENC_MAN", "MAN_REC", "ENC_REC_MAN"};
    selected_frequencies = {1, "theta"; 2, "Low Alpha"; 3, "High Alpha"};

    channel_labels = grandavg_data.data_exp.PRE.ENC.label;
    Table = struct();

    % Loop through RET and MAN sheets
    for n = 1:length(sheets)
        sheet = sheets{n};
        if sheet == "RET"
            comparisons = comparisons_ret;
        else
            comparisons = comparisons_man;
        end
        comparison_name = sprintf("%s_%s", test, sheet);

        % Import behavioural data
        opts = spreadsheetImportOptions("NumVariables", 2);
        opts.Sheet = comparison_name;
        opts.VariableNames = ["Participant", "Score"];
        opts.VariableTypes = ["double", "double"];
        opts = setvaropts(opts, ["Participant", "Score"], "EmptyFieldRule", "auto");

        behavioural_data = readtable(behaviour_data_folder, opts, "UseExcel", false);
        matrix = behavioural_data;
        clear opts

        % Reshape neurophysiological data and join
        [participants, channels, frequencies] = size(final_correlations.ENC_RET);
        column_names = cell(1, channels * frequencies);

        for y = 1:length(comparisons)
            comp = comparisons{y};

            index = 1;
            for f = 1:size(selected_frequencies, 1)
                for c = 1:channels
                    column_names{index} = sprintf('%s_%s_%s', comp, selected_frequencies{f, 2}, channel_labels{c});
                    index = index + 1;
                end
            end

            data_matrix = zeros(participants, channels * frequencies);
            index = 1;
            for f = 1:frequencies
                for c = 1:channels
                    data_matrix(:, index) = final_correlations.(comp)(:, c, f);
                    index = index + 1;
                end
            end

            Table.(comp) = array2table(data_matrix, 'VariableNames', column_names);
            Table.(comp) = addvars(Table.(comp), (1:participants)', 'Before', 1, 'NewVariableNames', 'Participant');
            matrix = join(Table.(comp), matrix, 'Keys', 'Participant');
        end

        % Split into groups
        nExp = size(grandavg_data.data_exp.PRE.ENC.powspctrm,1);
        tDCS = matrix(1:nExp, :);
        Control = matrix(nExp+1:end, :);

        % Export tables
        filename_full = sprintf("%s.xlsx", comparison_name);
        filename_tDCS = sprintf("tDCS_%s.xlsx", comparison_name);
        filename_control = sprintf("Control_%s.xlsx", comparison_name);
        writetable(matrix, fullfile(data_folder, filename_full));
        writetable(tDCS, fullfile(data_folder, filename_tDCS));
        writetable(Control, fullfile(data_folder, filename_control));

        fprintf('Exported: %s\n', comparison_name);
    end
end