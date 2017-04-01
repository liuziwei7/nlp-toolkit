#coding=utf-8

import thulac
import os

dir_input = "./data/"
file_output = "./results/tokenization/tokens_raw.txt"

file_input_temp = "./temp/input_temp.txt"
file_output_temp = "./temp/output_temp.txt"

fid_output = open(file_output, 'w')

tokenizer = thulac.thulac(filt=True, deli='/') #设置模式为分词和词性标注模式

for file_txt in os.listdir(dir_input):
	if file_txt.endswith(".txt"):

		file_input = dir_input + file_txt

		with open(file_input, 'r') as fid_input:
			for line in fid_input:
				
				fid_input_temp = open(file_input_temp, 'w')
				fid_input_temp.write(line)
				fid_input_temp.close()
				
				try:	
					tokenizer.cut_f(file_input_temp, file_output_temp) #根据参数运行分词和词性标注程序，从input_file文件中读入，输出结果output_file
				
					fid_output_temp = open(file_output_temp, 'r')
					tokens_cur = fid_output_temp.read()
					fid_output_temp.close()

					fid_output.write(tokens_cur)	
				except:
					print("Unexpected Error !!!")

fid_output.close()
