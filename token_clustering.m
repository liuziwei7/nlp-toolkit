clear; clc;

file_tokens_filtered = './results/filtering/tokens_filtered.txt';
file_tokens_association = './results/clustering/tokens_association.txt';
file_cooccurrence_tokens = './results/clustering/cooccurrence_tokens.mat';

type_association = 'specific'; % 'specific', 'global_pruning' or 'local_pruning'
num_tokens_visualize = 100;
threshold_association = 1;
threshold_association_sum = 200;

fid_tokens_filtered = fopen(file_tokens_filtered, 'rt');
lines = textscan(fid_tokens_filtered, '%s');
fclose(fid_tokens_filtered);

tokens = lines{1};
num_tokens = length(tokens);

tokens_base = unique(tokens);
num_tokens_base = length(tokens_base);
mat_freq = zeros(num_tokens_base, num_tokens_base, 'uint16');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 11-window sliding

for id_token = 6:1:num_tokens - 5

	idx_base_prev_5 = find(ismember(tokens_base, tokens{id_token - 5}));
	idx_base_prev_4 = find(ismember(tokens_base, tokens{id_token - 4}));
	idx_base_prev_3 = find(ismember(tokens_base, tokens{id_token - 3}));
	idx_base_prev_2 = find(ismember(tokens_base, tokens{id_token - 2}));
	idx_base_prev = find(ismember(tokens_base, tokens{id_token - 1}));
	idx_base_cur = find(ismember(tokens_base, tokens{id_token}));
	idx_base_next = find(ismember(tokens_base, tokens{id_token + 1}));
	idx_base_next_2 = find(ismember(tokens_base, tokens{id_token + 2}));
	idx_base_next_3 = find(ismember(tokens_base, tokens{id_token + 3}));
	idx_base_next_4 = find(ismember(tokens_base, tokens{id_token + 4}));
	idx_base_next_5 = find(ismember(tokens_base, tokens{id_token + 5}));

	mat_freq(idx_base_cur, idx_base_prev_5) = mat_freq(idx_base_cur, idx_base_prev_5) + 1;
	mat_freq(idx_base_cur, idx_base_prev_4) = mat_freq(idx_base_cur, idx_base_prev_4) + 1;
	mat_freq(idx_base_cur, idx_base_prev_3) = mat_freq(idx_base_cur, idx_base_prev_3) + 1;
	mat_freq(idx_base_cur, idx_base_prev_2) = mat_freq(idx_base_cur, idx_base_prev_2) + 1;
	mat_freq(idx_base_cur, idx_base_prev) = mat_freq(idx_base_cur, idx_base_prev) + 1;
	mat_freq(idx_base_cur, idx_base_next) = mat_freq(idx_base_cur, idx_base_next) + 1;
	mat_freq(idx_base_cur, idx_base_next_2) = mat_freq(idx_base_cur, idx_base_next_2) + 1;
	mat_freq(idx_base_cur, idx_base_next_3) = mat_freq(idx_base_cur, idx_base_next_3) + 1;
	mat_freq(idx_base_cur, idx_base_next_4) = mat_freq(idx_base_cur, idx_base_next_4) + 1;
	mat_freq(idx_base_cur, idx_base_next_5) = mat_freq(idx_base_cur, idx_base_next_5) + 1;

	mat_freq(idx_base_prev_5, idx_base_cur) = mat_freq(idx_base_prev_5, idx_base_cur) + 1;
	mat_freq(idx_base_prev_4, idx_base_cur) = mat_freq(idx_base_prev_4, idx_base_cur) + 1;
	mat_freq(idx_base_prev_3, idx_base_cur) = mat_freq(idx_base_prev_3, idx_base_cur) + 1;
	mat_freq(idx_base_prev_2, idx_base_cur) = mat_freq(idx_base_prev_2, idx_base_cur) + 1;
	mat_freq(idx_base_prev, idx_base_cur) = mat_freq(idx_base_prev, idx_base_cur) + 1;
	mat_freq(idx_base_next, idx_base_cur) = mat_freq(idx_base_next, idx_base_cur) + 1;
	mat_freq(idx_base_next_2, idx_base_cur) = mat_freq(idx_base_next_2, idx_base_cur) + 1;
	mat_freq(idx_base_next_3, idx_base_cur) = mat_freq(idx_base_next_3, idx_base_cur) + 1;
	mat_freq(idx_base_next_4, idx_base_cur) = mat_freq(idx_base_next_4, idx_base_cur) + 1;
	mat_freq(idx_base_next_5, idx_base_cur) = mat_freq(idx_base_next_5, idx_base_cur) + 1;

	disp(['Processing Token ', num2str(id_token), '...']);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

id_token_specific = find(ismember(tokens_base, '艾滋'));

switch type_association

case 'specific'

	% Level 1
	indices_token = find(mat_freq(id_token_specific, :) > threshold_association);
	tokens_base_selected = tokens_base(indices_token);
	mat_freq_selected = mat_freq(indices_token, indices_token);

	% Level 2
	indices_association = [19:length(indices_token)];
	tokens_base_selected = tokens_base_selected(indices_association);
	mat_freq_selected = mat_freq_selected(indices_association, indices_association);

	num_tokens_association = length(indices_association);
	fid_tokens_association = fopen(file_tokens_association, 'wt');
	for id_token_association = 1:num_tokens_association
		token_association_cur = tokens_base_selected{id_token_association};
		fprintf(fid_tokens_association, [token_association_cur, '\n']);
	end
	fclose(fid_tokens_association);

	save(file_cooccurrence_tokens, 'mat_freq_selected', '-v7.3');

case 'global_pruning'

	mat_freq = triu(mat_freq);
	val_sorted = sort(mat_freq(:), 'descend');

	row_base_prev = 0;
	col_base_prev = 0;

	count = 0;
	id_token_visualize = 0;

	fid_tokens_association = fopen(file_tokens_association, 'wt');

	while count < num_tokens_visualize

		id_token_visualize = id_token_visualize + 1;

		[row_base, col_base] = find(mat_freq == val_sorted(id_token_visualize));
		
		row_base_cur = row_base(1);
		col_base_cur = col_base(1);

		if row_base_cur ~= row_base_prev || col_base_cur ~= col_base_prev
			disp([tokens_base{row_base_cur}, ' ', tokens_base{col_base_cur}]);
			fprintf(fid_tokens_association, [tokens_base{row_base_cur}, ' ', tokens_base{col_base_cur}, '\n']);
			count = count + 1;
		end

		row_base_prev = row_base_cur;
		col_base_prev = col_base_cur;

	end

	fclose(fid_tokens_association);

case 'local_pruning'

	mat_freq_sum = sum(mat_freq, 1);
	indices_token = find(mat_freq_sum - double(diag(mat_freq)') > threshold_association_sum);
	tokens_base_selected = tokens_base(indices_token);
	mat_freq_selected = mat_freq(indices_token, indices_token);

	mat_freq_cur = mat_freq_selected(id_token_specific, :);
	val_sorted_cur = sort(mat_freq_cur, 'descend');

	col_base_prev = 0;

	count = 0;
	id_token_visualize = 0;

	fid_tokens_association = fopen(file_tokens_association, 'wt');

	indices_association = [];

	while count < num_tokens_visualize

		id_token_visualize = id_token_visualize + 1;

		col_base = find(mat_freq_cur == val_sorted_cur(id_token_visualize));
		
		col_base_cur = col_base(1);

		if col_base_cur ~= col_base_prev
			disp([tokens_base_selected{id_tokens_cur}, ' ', tokens_base_selected{col_base_cur}, ' ', num2str(val_sorted_cur(id_token_visualize))]);
			fprintf(fid_tokens_association, [tokens_base_selected{id_tokens_cur}, ' ', tokens_base_selected{col_base_cur}, ' ', num2str(val_sorted_cur(id_token_visualize)), '\n']);
			indices_association = [indices_association, col_base_cur];
			count = count + 1;
		end

		col_base_prev = col_base_cur;

	end

	fclose(fid_tokens_association);

end
