{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  numpy,
  opencv-python,
  pytestCheckHook,
  setuptools,
  simsimd,
  stringzilla,
}:

buildPythonPackage rec {
  pname = "albucore";
  version = "0.0.24";

  src = fetchFromGitHub {
    owner = "albumentations-team";
    repo = "albucore";
    tag = version;
    hash = "sha256-frVMPW3au/6vPRY89GIt7chCPkUMl13DpPqCPqIjz/o=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    numpy
    opencv-python
    simsimd
    stringzilla
  ];

  pyproject = true;
  pythonImportsCheck = [ "albucore" ];
  pythonRelaxDeps = [ "opencv-python" ];
  # albumentations doesn't support newer versions of albucore
  # and has been archived upstream in favor of relicensed `albumentationsx`
  passthru.skipBulkUpdate = true;

  meta = {
    description = "High-performance image processing library to optimize and extend Albumentations with specialized functions for image transformations";
    homepage = "https://github.com/albumentations-team/albucore";
    changelog = "https://github.com/albumentations-team/albucore/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bcdarwin ];
  };
}
