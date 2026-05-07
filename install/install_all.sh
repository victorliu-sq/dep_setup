#!/usr/bin/env bash
set -euo pipefail

# --- Installation Config
export INSTALLER_DIR="${INSTALLER_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
export DEP_SETUP_DIR="${DEP_SETUP_DIR:-$(cd "${INSTALLER_DIR}/.." && pwd)}"
export PROJECT_DIR="${PROJECT_DIR:-$(cd "${DEP_SETUP_DIR}/.." && pwd)}"
export SCRIPTS_DIR="${SCRIPTS_DIR:-${PROJECT_DIR}/scripts}"
export DEPS_DIR="${DEPS_DIR:-${PROJECT_DIR}/deps}"
export DEPS_TMP_DIR="${DEPS_TMP_DIR:-${DEPS_DIR}/tmp}"
export CONDA_ENV_NAME="${CONDA_ENV_NAME:-rayjoin-env}"

if ! declare -F download >/dev/null 2>&1; then
  download() {
    local url="$1" out="$2"
    if command -v curl >/dev/null 2>&1; then
      curl -L "$url" -o "$out"
    elif command -v wget >/dev/null 2>&1; then
      wget "$url" -O "$out"
    else
      echo "ERROR: need curl or wget" >&2
      exit 1
    fi
  }
  export -f download
fi

# --- Create Directories ----------------------------------------------------
mkdir -p \
  "${DEPS_DIR}" \
  "${DEPS_TMP_DIR}"

# --- Install optix ----------------------------------------------------
# bash + path (single argument) + subsequent arguments
bash "${INSTALLER_DIR}/installer_optix.sh"

# --- Install gflags  ----------------------------------------------------
bash "${INSTALLER_DIR}/installer_gflags.sh"

# --- Install glog  ----------------------------------------------------
bash "${INSTALLER_DIR}/installer_glog.sh"

# --- Install slang ----------------------------------------------------
bash "${INSTALLER_DIR}/installer_slang.sh"

# --- Install Vulkan ----------------------------------------------------
bash "${INSTALLER_DIR}/installer_vulkan.sh"

# --- Install LBVH
bash "${INSTALLER_DIR}/installer_lbvh.sh"

# --- Install VMA
bash "${INSTALLER_DIR}/installer_vma.sh"

# --- Install gtest  ----------------------------------------------------
bash "${INSTALLER_DIR}/installer_gtest.sh"

# --- Install google benchmark  ----------------------------------------------------
#bash "${INSTALLER_DIR}/installer_gbenchmark.sh"

bash "${INSTALLER_DIR}/installer_python.sh"

# --- Install Ligra ----------------------------------------------------
#bash "${INSTALLER_DIR}/install_ligra_openmp.sh" # Install Ligra

# --- Install Gunrock ----------------------------------------------------
#bash "${INSTALLER_DIR}/install_gunrock.sh" # Install Gunrock

#export LD_LIBRARY_PATH="${DEPS_DIR}/lib:${PROJECT_DIR}/bin:${LD_LIBRARY_PATH:-}"
#echo "[INFO] LD_LIBRARY_PATH set to: $LD_LIBRARY_PATH"

# remove the tmp directory
rm -rf "${DEPS_TMP_DIR}"
