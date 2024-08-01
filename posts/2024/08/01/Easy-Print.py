
#!/usr/bin/env python3
import os
import sys
import argparse

def list_files(directory, exclude, output_file):
    # 获取当前脚本的文件名
    script_name = os.path.basename(__file__)

    # 打开输出文件
    with open(output_file, 'w', encoding='utf-8') as f:
        for root, dirs, files in os.walk(directory):
            # 过滤掉排除的目录和以 '.' 开头的目录
            dirs[:] = [d for d in dirs if os.path.join(root, d) not in exclude and not d.startswith('.')]
            for file_name in files:
                if file_name.startswith('.'):
                    continue
                file_path = os.path.join(root, file_name)
                if file_path not in exclude and file_name != script_name:
                    f.write("{}\n".format(file_path))
                    f.write("*********************\n")
                    try:
                        # 以 UTF-8 编码读取文件内容
                        with open(file_path, 'r', encoding='utf-8') as file:
                            f.write(file.read())
                            f.write("\n\n")
                    except (UnicodeDecodeError, OSError):
                        try:
                            # 尝试以 GBK 编码读取文件内容
                            with open(file_path, 'r', encoding='gbk') as file:
                                f.write(file.read())
                                f.write("\n\n")
                        except Exception as e:
                            f.write("Error reading file: {}\n\n".format(e))

def main():
    # 创建参数解析器
    parser = argparse.ArgumentParser(description="列出文件及其内容")
    parser.add_argument('-d', '--directory', default='.', help="开始列出文件的目录")
    parser.add_argument('-n', '--no-print', nargs='+', default=[], help="要排除的文件或目录")
    parser.add_argument('-o', '--output-file', default='easy-print.txt', help="输出文件名")

    # 解析参数
    args = parser.parse_args()

    output_file = args.output_file
    directory = os.path.abspath(args.directory)
    exclude = [os.path.abspath(item) for item in args.no_print]

    # 调用 list_files 函数
    list_files(directory, exclude, output_file)
    print("输出已写入到 {}".format(output_file))

if __name__ == "__main__":
    # 没有参数时执行默认行为
    if len(sys.argv) == 1:
        list_files(os.getcwd(), [], 'easy-print.txt')
        print("输出已写入到 easy-print.txt")
    else:
        main()
