{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  numpy,
  pbr,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "fastremap";
  version = "1.19.0";

  src = fetchFromGitHub {
    owner = "seung-lab";
    repo = "fastremap";
    tag = version;
    hash = "sha256-fPDgCpCJrMomxr0dicM9NBqzH4s+/Ux37hTsnsGts2g=";
  };

  env.PBR_VERSION = version;

  nativeCheckInputs = [
    pytestCheckHook
  ];

  preCheck = "rm -r fastremap/";

  build-system = [
    cython
    numpy
    pbr
    setuptools
  ];

  dependencies = [
    numpy
  ];

  pyproject = true;

  pythonImportsCheck = [
    "fastremap"
  ];

  meta = {
    description = "Remap, mask, renumber, unique, and in-place transposition of 3D labeled images and point clouds";
    homepage = "https://github.com/seung-lab/fastremap";
    changelog = "https://github.com/seung-lab/fastremap/releases/tag/${src.tag}";
    license = lib.licenses.lgpl3Only;
    maintainers = with lib.maintainers; [ bcdarwin ];
  };
}
