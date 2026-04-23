#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="${1:-$ROOT_DIR/data/TUM}"

mkdir -p "$DATA_DIR"
cd "$DATA_DIR"

download_and_extract() {
    local url="$1"
    local archive_name
    archive_name="$(basename "$url")"

    if [ ! -d "${archive_name%.tgz}" ]; then
        wget -nc "$url"
        tar -xvzf "$archive_name"
        rm -f "$archive_name"
    fi
}

download_and_extract "https://vision.in.tum.de/rgbd/dataset/freiburg1/rgbd_dataset_freiburg1_desk.tgz"
download_and_extract "https://vision.in.tum.de/rgbd/dataset/freiburg2/rgbd_dataset_freiburg2_xyz.tgz"
download_and_extract "https://vision.in.tum.de/rgbd/dataset/freiburg3/rgbd_dataset_freiburg3_long_office_household.tgz"
