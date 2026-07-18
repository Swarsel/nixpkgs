{
  lib,
  fetchFromGitHub,
  python3Packages,
  versionCheckHook,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "nvitop";
  version = "1.7.1";

  src = fetchFromGitHub {
    owner = "XuehaiPan";
    repo = "nvitop";
    tag = "v${finalAttrs.version}";
    hash = "sha256-x6ONS9tGzRa+z2djZ17w14lyyluuTMam75TwujHrH1E=";
  };

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  __structuredAttrs = true;
  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    psutil
    nvidia-ml-py
  ];

  pyproject = true;
  pythonImportsCheck = [ "nvitop" ];
  pythonRelaxDeps = [ "nvidia-ml-py" ];

  meta = {
    description = "Interactive NVIDIA-GPU process viewer, the one-stop solution for GPU process management";
    homepage = "https://github.com/XuehaiPan/nvitop";
    changelog = "https://github.com/XuehaiPan/nvitop/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ GaetanLepage ];
    platforms = with lib.platforms; linux;
  };
})
