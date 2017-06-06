function caret_file_to_ascii(file)
unix(['sh /Applications/caret/bin_macosx64/caret_command -file-convert -format-convert ASCII ' file]);