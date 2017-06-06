function caret_file_to_ascii(file)
unix(['caret_command -file-convert -format-convert ASCII ' file]);