{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # nativeBuildInputs
  cmake,
  # build-system
  ninja,
  # tests
  pytestCheckHook,
  scikit-build-core,
  scipy,
  # dependencies
  torch,
}:

buildPythonPackage (finalAttrs: {
  pname = "deepwave";
  version = "0.0.27";

  src = fetchFromGitHub {
    owner = "ar4";
    repo = "deepwave";
    tag = "v${finalAttrs.version}";
    hash = "sha256-zOyoycCJjx4HJEnkAD5r7d+qxO5A+d0dCgx2oRjxPuU=";
  };

  nativeBuildInputs = [
    cmake
  ];

  nativeCheckInputs = [
    pytestCheckHook
    scipy
  ];

  __structuredAttrs = true;

  build-system = [
    ninja
    scikit-build-core
  ];

  dependencies = [
    torch
  ];

  dontUseCmakeConfigure = true;
  pyproject = true;
  pythonImportsCheck = [ "deepwave" ];

  meta = {
    description = "Wave propagation modules for PyTorch";
    homepage = "https://github.com/ar4/deepwave";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.intersectLists lib.platforms.x86_64 lib.platforms.linux;
  };
})
