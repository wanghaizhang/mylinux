#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT="/srv/mylinux"
BR="/srv/buildroot"
OUT="${BR}/build"
DL="/srv/buildroot-dl"
DEFCONFIG="mylinux_x86_64_defconfig"
LOG="${PROJECT}/build-local.log"

for path in \
  "${BR}/Makefile" \
  "${PROJECT}/external.desc" \
  "${PROJECT}/external.mk" \
  "${PROJECT}/Config.in" \
  "${PROJECT}/configs/${DEFCONFIG}"
do
  if [[ ! -e "${path}" ]]; then
    echo "错误：找不到 ${path}"
    exit 1
  fi
done

mkdir -p "${OUT}" "${DL}"

echo "项目目录：${PROJECT}"
echo "Buildroot：${BR}"
echo "输出目录：${OUT}"
echo "下载缓存：${DL}"

# 如果已经有配置，就保留它；只有首次构建才初始化 defconfig。
if [[ ! -f "${OUT}/.config" ]]; then
  echo "首次构建：初始化 defconfig"
  make -C "${BR}" \
    BR2_EXTERNAL="${PROJECT}" \
    O="${OUT}" \
    BR2_DL_DIR="${DL}" \
    "${DEFCONFIG}"
else
  echo "检测到现有 .config：保留当前配置"
fi

echo "开始编译，日志：${LOG}"

set -o pipefail
make -C "${BR}" \
  BR2_EXTERNAL="${PROJECT}" \
  O="${OUT}" \
  BR2_DL_DIR="${DL}" \
  -j8 2>&1 | tee -a "${LOG}"

echo
echo "编译结束，检查输出目录：${OUT}/images"
ls -lh "${OUT}/images"

echo
echo "提示：请确认 disk.img 存在，并在虚拟机中验证能否启动。"
