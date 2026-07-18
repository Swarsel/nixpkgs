# Warning: use the same CUDA version as torch-bin.
#
# Precompiled wheels can be found at:
# https://download.pytorch.org/whl/torch_stable.html

# To add a new version, run "prefetch.sh 'new-version'" to paste the generated file as follows.

version:
builtins.getAttr version {
  "2.12.0" = {
    aarch64-darwin-310 = {
      hash = "sha256-GDS9mE+KL08WvfvuzKkUYYSyIKpGJ2v1dWc1tdrhKBI=";
      name = "torch-2.12.0-cp310-none-macosx_14_0_arm64.whl";
      url = "https://download.pytorch.org/whl/cpu/torch-2.12.0-cp310-cp310-macosx_14_0_arm64.whl";
    };

    aarch64-darwin-311 = {
      hash = "sha256-EIAv04O7/tZGIS52WnLDfSGFIF1PJusZeiVOisfdyyU=";
      name = "torch-2.12.0-cp311-none-macosx_14_0_arm64.whl";
      url = "https://download.pytorch.org/whl/cpu/torch-2.12.0-cp311-cp311-macosx_14_0_arm64.whl";
    };

    aarch64-darwin-312 = {
      hash = "sha256-tBM535PUkUNeeQ/4vLrhwM53cXWIm/0SgdEZhieT5qI=";
      name = "torch-2.12.0-cp312-none-macosx_14_0_arm64.whl";
      url = "https://download.pytorch.org/whl/cpu/torch-2.12.0-cp312-cp312-macosx_14_0_arm64.whl";
    };

    aarch64-darwin-313 = {
      hash = "sha256-kN1Yel9hv+EwcUi1geIIT8W8SgbiuQog6aNrgQh/8Ws=";
      name = "torch-2.12.0-cp313-none-macosx_14_0_arm64.whl";
      url = "https://download.pytorch.org/whl/cpu/torch-2.12.0-cp313-cp313-macosx_14_0_arm64.whl";
    };

    aarch64-darwin-314 = {
      hash = "sha256-99+uSlGRl9+gUOmNjjY3ig+1iZYlqHXCtURFAFouQE4=";
      name = "torch-2.12.0-cp314-cp314-macosx_14_0_arm64.whl";
      url = "https://download.pytorch.org/whl/cpu/torch-2.12.0-cp314-cp314-macosx_14_0_arm64.whl";
    };

    aarch64-linux-310 = {
      hash = "sha256-x0pEmtf5e4eXNLWk8QkqkbF4DizVJew2nCn9mHfvc8A=";
      name = "torch-2.12.0+cpu-cp310-cp310-manylinux_2_28_aarch64.whl";
      url = "https://download.pytorch.org/whl/cpu/torch-2.12.0%2Bcpu-cp310-cp310-manylinux_2_28_aarch64.whl";
    };

    aarch64-linux-311 = {
      hash = "sha256-Ts2OzbnqGv+l810QUBgJ1i3HE/feljXoCY52DdvrhSw=";
      name = "torch-2.12.0+cpu-cp311-cp311-manylinux_2_28_aarch64.whl";
      url = "https://download.pytorch.org/whl/cpu/torch-2.12.0%2Bcpu-cp311-cp311-manylinux_2_28_aarch64.whl";
    };

    aarch64-linux-312 = {
      hash = "sha256-zi3biAsIE/zJGnN/CP3Zc6gRWnTGTMs06cCaeWS01Eg=";
      name = "torch-2.12.0+cpu-cp312-cp312-manylinux_2_28_aarch64.whl";
      url = "https://download.pytorch.org/whl/cpu/torch-2.12.0%2Bcpu-cp312-cp312-manylinux_2_28_aarch64.whl";
    };

    aarch64-linux-313 = {
      hash = "sha256-aLfd1NtGA6A+EG50xwmMjYyJQ9M8HlraAJykzYhXWcM=";
      name = "torch-2.12.0+cpu-cp313-cp313-manylinux_2_28_aarch64.whl";
      url = "https://download.pytorch.org/whl/cpu/torch-2.12.0%2Bcpu-cp313-cp313-manylinux_2_28_aarch64.whl";
    };

    aarch64-linux-314 = {
      hash = "sha256-eXwGY2d5LJLrl8r7p/0Mqo10VeYHik7ogGMAdzeNw3I=";
      name = "torch-2.12.0+cpu-cp314-cp314-manylinux_2_28_aarch64.whl";
      url = "https://download.pytorch.org/whl/cpu/torch-2.12.0%2Bcpu-cp314-cp314-manylinux_2_28_aarch64.whl";
    };

    x86_64-linux-310 = {
      hash = "sha256-hFoXKaUq7HZh0bbauuiBXrFNurXHxnpf4LrxlKr6Ef4=";
      name = "torch-2.12.0+cu130-cp310-cp310-linux_x86_64.whl";
      url = "https://download.pytorch.org/whl/cu130/torch-2.12.0%2Bcu130-cp310-cp310-manylinux_2_28_x86_64.whl";
    };

    x86_64-linux-311 = {
      hash = "sha256-UDjwnuFhM5pSFF0Ab2BfYM6qc1Yn4uNRuTQZy6YGlsM=";
      name = "torch-2.12.0+cu130-cp311-cp311-linux_x86_64.whl";
      url = "https://download.pytorch.org/whl/cu130/torch-2.12.0%2Bcu130-cp311-cp311-manylinux_2_28_x86_64.whl";
    };

    x86_64-linux-312 = {
      hash = "sha256-n1EupRwXCnzBoEh8CPAVS3je+6TrhhnK0BMMhhXthSY=";
      name = "torch-2.12.0+cu130-cp312-cp312-linux_x86_64.whl";
      url = "https://download.pytorch.org/whl/cu130/torch-2.12.0%2Bcu130-cp312-cp312-manylinux_2_28_x86_64.whl";
    };

    x86_64-linux-313 = {
      hash = "sha256-/l/vt4SjcNG6SVneboe807NUQQQKmb/+MvXNA7vINMA=";
      name = "torch-2.12.0+cu130-cp313-cp313-linux_x86_64.whl";
      url = "https://download.pytorch.org/whl/cu130/torch-2.12.0%2Bcu130-cp313-cp313-manylinux_2_28_x86_64.whl";
    };

    x86_64-linux-314 = {
      hash = "sha256-P/c2b2kZIy8JnvcCw+vTUJyRqzfDZ+QIyzeZxr7SFKQ=";
      name = "torch-2.12.0+cu130-cp314-cp314-linux_x86_64.whl";
      url = "https://download.pytorch.org/whl/cu130/torch-2.12.0%2Bcu130-cp314-cp314-manylinux_2_28_x86_64.whl";
    };
  };
}
