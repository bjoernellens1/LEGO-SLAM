# LEGO-SLAM on JupyterHub

This repository is configured to run with the `lego_slam` conda environment and the `Python (LEGO-SLAM)` Jupyter kernel.

## Use

Shell:

```bash
conda activate lego_slam
cd /home/jovyan/work/LEGO-SLAM
```

Notebook:

- Select the kernel `Python (LEGO-SLAM)`.

## Notes

- The repository vendors a local `encoding/` package so LSeg imports work without relying on a fragile external `torch-encoding` build.
- `fast_gicp` and `diff_gaussian_rasterization` are installed into the `lego_slam` environment.
- `opencv-contrib-python-headless` is used instead of the GUI OpenCV wheel, which is a better fit for JupyterHub.

## Remaining manual asset

Download `demo_e200.ckpt` and place it at:

```text
Lseg/demo_e200.ckpt
```

The upstream README link still applies for that checkpoint.
