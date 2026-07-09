import re

with open('analyzer.txt') as f:
    lines = f.readlines()

warnings_to_fix = [
    'unused_field', 'unused_element', 'unused_local_variable', 
    'dead_code', 'unused_import'
]

for line in lines:
    line = line.strip()
    if any(w in line for w in warnings_to_fix):
        parts = line.split(' • ')
        if len(parts) >= 4:
            file_info = parts[-2]
            try:
                file_path, line_num, _ = file_info.split(':')
                line_num = int(line_num)
                
                with open(file_path, 'r') as code_file:
                    code_lines = code_file.readlines()
                    
                code_line = code_lines[line_num - 1]
                if code_line.startswith('// '):
                    code_lines[line_num - 1] = code_line[3:]
                elif code_line.strip().startswith('// '):
                    code_lines[line_num - 1] = code_line.replace('// ', '', 1)
                
                with open(file_path, 'w') as code_file:
                    code_file.writelines(code_lines)
                print(f'Undid {file_info}')
            except Exception as e:
                print(f"Error processing {file_info}: {e}")
