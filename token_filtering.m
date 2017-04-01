clear; clc;

file_tokens_raw = './results/tokenization/tokens_raw.txt';
file_tokens_filtered = './results/filtering/tokens_filtered.txt';

fid_tokens_raw = fopen(file_tokens_raw, 'rt');
lines = fscanf(fid_tokens_raw, '%c');
fclose(fid_tokens_raw);

tokens = strsplit(lines);
num_token = length(tokens);

fid_tokens_filtered = fopen(file_tokens_filtered, 'wt');

for id_token = 1:num_token

	token_cur = tokens{id_token};
	idx_slash = find(token_cur == '/');
	category_cur = token_cur(idx_slash + 1:end);

	if strcmp(category_cur, 'n') || strcmp(category_cur, 'a') || strcmp(category_cur, 'd')
		fprintf(fid_tokens_filtered, [token_cur(1:idx_slash - 1), '\n']);
	end

	disp(['Processing Token ', num2str(id_token), '...']);

end

fclose(fid_tokens_filtered);
