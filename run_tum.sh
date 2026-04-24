#!/bin/bash

# Usage: bash run_tum.sh /path/to/TUM [--disable_embeddings] [--dense_debug]
if [ -z "$1" ]; then
    echo "Usage: bash run_tum.sh <dataset_path>"
    echo "Example: bash run_tum.sh /path/to/TUM"
    exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Keep long-running outputs on shared storage so they survive workspace cleanup.
OUTPUT_PATH="${OUTPUT_PATH:-/home/jovyan/shared/LEGO-SLAM-experiments}"
DATASET_PATH="$1"
EXTRA_ARGS=()
RUN_DENSE_DEBUG=0
DISABLE_EMBEDDINGS=0

for arg in "${@:2}"; do
    case "$arg" in
        --dense_debug)
            RUN_DENSE_DEBUG=1
            ;;
        --disable_embeddings)
            DISABLE_EMBEDDINGS=1
            ;;
        *)
            EXTRA_ARGS+=("$arg")
            ;;
    esac
done

if [ -d "$DATASET_PATH/groundtruth" ]; then
    DATASET_SEARCH_ROOT="$DATASET_PATH/groundtruth"
else
    DATASET_SEARCH_ROOT="$DATASET_PATH"
fi

tr_pad() {
  local pad_length="$1" pad_string="$2" pad_type="$3"
  local pad length llength offset rlength

  pad="$(eval "printf '%0.${#pad_string}s' '${pad_string}'{1..$pad_length}")"
  pad="${pad:0:$pad_length}"

  if [[ "$pad_type" == "left" ]]; then
    while read -r line; do
      line="${line:0:$pad_length}"
      length="$(( pad_length - ${#line} ))"
      echo -n "${pad:0:$length}$line"
    done
  elif [[ "$pad_type" == "both" ]]; then
    while read -r line; do
      line="${line:0:$pad_length}"
      length="$(( pad_length - ${#line} ))"
      llength="$(( length / 2 ))"
      offset="$(( llength + ${#line} ))"
      rlength="$(( llength + (length % 2) ))"
      echo -n "${pad:0:$llength}$line${pad:$offset:$rlength}"
    done
  else
    while read -r line; do
      line="${line:0:$pad_length}"
      length="$(( pad_length - ${#line} ))"
      echo -n "$line${pad:${#line}:$length}"
    done
  fi
}

run_() {
    local dataset_path=$1
    local dataset_name=$2
    local config=$3
    local result_txt=$4
    local keyframe_th=$5
    local knn_maxd=$6
    local overlapped_th=$7
    local max_correspondence_distance=$8
    local trackable_opacity_th=$9
    local overlapped_th2=${10}
    local downsample_rate=${11}
    local post_training_iter=${12}
    local eval_ratio=${13}
    local edge_weight=${14}
    local n_trackable_keyframes=${15}
    local pose_lr_rate=${16}
    local loopclosing_global_correspondence_distance=${17}
    local loopclosing_local_correspondence_distance=${18}
    local loop_constraint_noise=${19}
    local max_mapping_keyframes=${20}
    local extra_flags=("${EXTRA_ARGS[@]}")

    echo "run $dataset_name" >> "${result_txt}"
    python -W ignore "$ROOT_DIR/lego_slam.py" \
        --dataset_path "$dataset_path" \
        --config "$config" \
        --output_path "$OUTPUT_PATH/$RESULT_SUBDIR/$dataset_name/init/" \
        --keyframe_th "$keyframe_th" \
        --knn_maxd "$knn_maxd" \
        --overlapped_th "$overlapped_th" \
        --max_correspondence_distance "$max_correspondence_distance" \
        --trackable_opacity_th "$trackable_opacity_th" \
        --overlapped_th2 "$overlapped_th2" \
        --downsample_rate "$downsample_rate" \
        --post_training_iter "$post_training_iter" \
        --eval_ratio "$eval_ratio" \
        --save_results \
        --speedup \
        --system_fps_limit 15.0 \
        --enable_loop_closing \
        --n_trackable_keyframes "$n_trackable_keyframes" \
        --pose_lr_rate "$pose_lr_rate" \
        --loopclosing_global_correspondence_distance "$loopclosing_global_correspondence_distance" \
        --loopclosing_local_correspondence_distance "$loopclosing_local_correspondence_distance" \
        --loop_constraint_noise "$loop_constraint_noise" \
        --max_mapping_keyframes "$max_mapping_keyframes" \
        --edge_weight "$edge_weight" \
        "${extra_flags[@]}" \
        >> "${result_txt}"
    wait
}

run_if_exists() {
    local dataset_name=$1
    local config=$2
    local dataset_path="$DATASET_SEARCH_ROOT/$dataset_name"

    if [ -d "$dataset_path" ]; then
        run_ "$dataset_path" "$dataset_name" "$config" "$txt_file" "$keyframe_th" "$knn_maxd" "$overlapped_th" "$max_correspondence_distance" "$trackable_opacity_th" "$overlapped_th2" "$downsample_rate" "$post_training_iter" "$eval_ratio" "$edge_weight" "$n_trackable_keyframes" "$pose_lr_rate" "$loopclosing_global_correspondence_distance" "$loopclosing_local_correspondence_distance" "$loop_constraint_noise" "$max_mapping_keyframes"
    else
        echo "Skipping missing TUM sequence: $dataset_name"
    fi
}

run_tum_dense() {
    local dataset_name="rgbd_dataset_freiburg2_xyz"
    local config="configs/TUM/rgbd_dataset_freiburg2_xyz.txt"
    local dataset_path="$DATASET_SEARCH_ROOT/$dataset_name"

    if [ -d "$dataset_path" ]; then
        run_ "$dataset_path" "$dataset_name" "$config" "$txt_file" "$keyframe_th" "$knn_maxd" "$overlapped_th" "$max_correspondence_distance" "$trackable_opacity_th" "$overlapped_th2" "$downsample_rate" "$post_training_iter" "$eval_ratio" "$edge_weight" "$n_trackable_keyframes" "$pose_lr_rate" "$loopclosing_global_correspondence_distance" "$loopclosing_local_correspondence_distance" "$loop_constraint_noise" "$max_mapping_keyframes"
    else
        echo "Skipping missing TUM sequence: $dataset_name"
    fi
}

overlapped_th=1e-3
max_correspondence_distance=0.03
knn_maxd=99999.0
trackable_opacity_th=0.09
overlapped_th2=5e-4
downsample_rate=5
keyframe_th=0.84
post_training_iter=0
eval_ratio=1.0
edge_weight=0.1
n_trackable_keyframes=100
pose_lr_rate=0.5
loopclosing_global_correspondence_distance=0.1
loopclosing_local_correspondence_distance=0.03
loop_constraint_noise=1e-2
max_mapping_keyframes=130

RESULT_SUBDIR="tum"
txt_file="$ROOT_DIR/tum_results.txt"

if [ "$RUN_DENSE_DEBUG" -eq 1 ]; then
    RESULT_SUBDIR="tum_dense"
    txt_file="$ROOT_DIR/tum_dense_results.txt"
    keyframe_th=0.55
    downsample_rate=2
    n_trackable_keyframes=300
    max_mapping_keyframes=400
fi

if [ "$DISABLE_EMBEDDINGS" -eq 1 ]; then
    EXTRA_ARGS=(--disable_embeddings "${EXTRA_ARGS[@]}")
fi

if [ "$RUN_DENSE_DEBUG" -eq 1 ]; then
    run_tum_dense
else
    run_if_exists "rgbd_dataset_freiburg1_desk" "configs/TUM/rgbd_dataset_freiburg1_desk.txt"
    run_if_exists "rgbd_dataset_freiburg2_xyz" "configs/TUM/rgbd_dataset_freiburg2_xyz.txt"
    run_if_exists "rgbd_dataset_freiburg3_long_office_household" "configs/TUM/rgbd_dataset_freiburg3_long_office_household.txt"
fi
