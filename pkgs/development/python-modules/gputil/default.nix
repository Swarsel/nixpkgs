{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  distutils,
  # build-system
  setuptools,
}:

buildPythonPackage rec {
  pname = "gputil";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "anderskm";
    repo = "gputil";
    tag = "v${version}";
    hash = "sha256-iOyB653BMmDBtK1fM1ZyddjlnaypsuLMOV0sKaBt+yE=";
  };

  build-system = [ setuptools ];
  dependencies = [ distutils ];
  pyproject = true;
  pythonImportsCheck = [ "GPUtil" ];

  meta = {
    description = "Getting GPU status from NVIDA GPUs using nvidia-smi";
    homepage = "https://github.com/anderskm/gputil";
    changelog = "https://github.com/anderskm/gputil/releases/tag/${src.tag}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      doronbehar
    ];
  };
}
