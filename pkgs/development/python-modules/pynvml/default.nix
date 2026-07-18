{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cudaPackages,
  nvidia-ml-py,
  pynvml,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pynvml";
  version = "13.0.1";

  src = fetchFromGitHub {
    owner = "gpuopenanalytics";
    repo = "pynvml";
    tag = version;
    hash = "sha256-Jwj3cm0l7qR/q5jzwKbD52L7ePYCdzXrYFOceMA776M=";
  };

  doCheck = false;
  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
  ];

  dependencies = [ nvidia-ml-py ];
  pyproject = true;

  pythonImportsCheck = [
    "pynvml_utils"
  ];

  pythonRelaxDeps = [
    "nvidia-ml-py"
  ];

  passthru.tests.tester-nvmlInit = cudaPackages.writeGpuTestPython { libraries = [ pynvml ]; } ''
    from pynvml_utils import nvidia_smi  # noqa: F401
    nvsmi = nvidia_smi.getInstance()
    print(nvsmi.DeviceQuery('memory.free, memory.total'))
  '';

  meta = {
    description = "Unofficial Python bindings for the NVIDIA Management Library";
    homepage = "https://github.com/gpuopenanalytics/pynvml";
    changelog = "https://github.com/gpuopenanalytics/pynvml?tab=readme-ov-file#release-notes";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.bcdarwin ];
  };
}
