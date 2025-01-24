#!/bin/bash

# 在脚本开头添加

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# 检查参数

if [ "$#" -lt 3 ]; then
    echo "Usage: $0 <input_folder> <output_folder> <csv_file> [watermark_mode]"
    echo "Example: $0 ./input ./output users.csv [full|end]"
    echo "watermark_mode: full - 全程水印, end - 仅最后一分钟水印(默认)"
    exit 1
fi

# 定义参数

INPUT_FOLDER="$1"
OUTPUT_FOLDER="$2"
CSV_FILE="$3"
LOG_FILE="watermark.log"

# 支持的视频格式

VIDEO_FORMATS="mp4|mkv|avi|mov"

# 支持的图片格式

IMAGE_FORMATS="jpg|jpeg|png|webp"

# 添加水印模式参数
WATERMARK_MODE="${4:-full}" # 如果没有第4个参数，默认为 "end"

# 初始化日志

echo "Processing started at $(date)" >"$LOG_FILE"

# 检查必要的命令是否存在

check_commands() {
    for cmd in ffmpeg magick; do
        if ! command -v $cmd &>/dev/null; then
            echo "Error: $cmd is not installed"
            exit 1
        fi
    done
}

# 处理单个视频文件

process_video() {
    local input_file="$1"
    local wxid="$2"
    local nickname="$3"
    local user_output_dir="$4"

    local rel_path="${input_file#$INPUT_FOLDER/}"
    local output_dir="$user_output_dir/$(dirname "$rel_path")"
    local filename=$(basename "$input_file")
    local output_file="$output_dir/${filename%.*}_${wxid}.${filename##*.}"

    mkdir -p "$output_dir"

    echo "Processing video: $rel_path for $wxid ($nickname)"

    # 根据水印模式设置时间过滤器
    if [ "$WATERMARK_MODE" = "full" ]; then
        time_filter="1" # 始终显示
    else
        # 获取视频总时长（秒）
        duration=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$input_file")
        start_time=$(echo "$duration - 60" | bc)
        # 如果视频长度小于60秒，从开始就添加水印
        if (($(echo "$start_time < 0" | bc -l))); then
            time_filter="1"
        else
            time_filter="gte(t,${start_time})"
        fi
    fi

    ffmpeg -nostdin -hide_banner -loglevel error \
        -i "$input_file" \
        -vf "drawtext=text='仅供以下人员查看学习，请勿公开传播，否则可能承担法律责任':fontfile=/System/Library/Fonts/PingFang.ttc:fontsize=16:fontcolor=white@0.5:x=w-tw-10:y=h-th-30:enable='${time_filter}',drawtext=text='微信号或 ID：${wxid}(${nickname})':fontfile=/System/Library/Fonts/PingFang.ttc:fontsize=16:fontcolor=white@0.5:x=w-tw-10:y=h-th-10:enable='${time_filter}'" \
        -c:v libx264 \
        -codec:a copy \
        -y \
        "$output_file"

    local status=$?
    if [ $status -eq 0 ]; then
        echo "Success: $output_file"
    else
        echo "Error processing video: $input_file (exit code: $status)"
        echo "Check $LOG_FILE for details"
    fi
}

# 处理单图片文件

process_image() {
    local input_file="$1"
    local wxid="$2"
    local nickname="$3"
    local user_output_dir="$4"

    local rel_path="${input_file#$INPUT_FOLDER/}"
    rel_path=$(echo "$rel_path" | sed 's|^\./||')
    local output_dir="$user_output_dir/$(dirname "$rel_path")"
    local filename=$(basename "$input_file")
    local output_file="$output_dir/${filename%.*}_${wxid}.${filename##*.}"

    mkdir -p "$output_dir"

    echo "Processing image: $rel_path for $wxid"
    local date_str=$(date '+%Y-%m-%d')

    magick "$input_file" \
        \( -size 300x300 xc:none \
        -gravity center \
        -font "/System/Library/Fonts/PingFang.ttc" \
        -pointsize 26 \
        -fill black \
        -draw "rotate -45 text 0,0 'ID：${wxid}_${date_str}，勿公开传播\n\n否则可能承担法律责任'" \
        -channel A -evaluate multiply 0.15 \
        -write mpr:watermark +delete \
        -size 2000x2000 tile:mpr:watermark \) \
        -compose over -composite \
        "$output_file" 2>>"$LOG_FILE"

    if [ $? -eq 0 ]; then
        echo "Success: $output_file"
        echo "${wxid},${nickname},$(date '+%Y-%m-%d %H:%M:%S')" >>"id_mapping.csv"
    else
        echo "Error processing image: $input_file"
    fi
}

# 处理目录中的所有文件

process_directory() {
    local wxid="$1"
    local nickname="$2"
    local user_output_dir="$3"

    # 使用定义好的视频格式，用 -iname 替代 regex
    for format in ${VIDEO_FORMATS//|/ }; do
        local video_files=($(find "$INPUT_FOLDER" -type f -iname "*.${format}"))
        for file in "${video_files[@]}"; do
            process_video "$file" "$wxid" "$nickname" "$user_output_dir"
        done
    done

    # 使用定义好的图片格式，用 -iname 替代 regex
    for format in ${IMAGE_FORMATS//|/ }; do
        local image_files=($(find "$INPUT_FOLDER" -type f -iname "*.${format}"))
        for file in "${image_files[@]}"; do
            process_image "$file" "$wxid" "$nickname" "$user_output_dir"
        done
    done
}

# 主程序

main() {
    check_commands

    if [ ! -f "$CSV_FILE" ]; then
        echo "Error: CSV file not found!"
        exit 1
    fi

    if [ ! -d "$INPUT_FOLDER" ]; then
        echo "Error: Input folder not found!"
        exit 1
    fi

    echo "Cleaning output directory: $OUTPUT_FOLDER"
    rm -rf "$OUTPUT_FOLDER"
    mkdir -p "$OUTPUT_FOLDER"

    echo "unique_id,wxid,nickname,timestamp" >"id_mapping.csv"

    while IFS=, read -r wxid nickname || [ -n "$wxid" ]; do
        wxid=$(echo "$wxid" | tr -d '"' | tr -d ' ')
        nickname=$(echo "$nickname" | tr -d '"' | tr -d ' ')

        local user_output_dir="$OUTPUT_FOLDER/$wxid"
        mkdir -p "$user_output_dir"

        echo "Processing for WeChat ID: $wxid, Nickname: $nickname"
        process_directory "$wxid" "$nickname" "$user_output_dir"
    done <"$CSV_FILE"

    echo "Processing complete! Check $LOG_FILE for details."

}

# 运行主程序

main
