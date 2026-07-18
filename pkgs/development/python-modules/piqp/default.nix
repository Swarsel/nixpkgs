{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  cmake,
  cpu_features,
  # buildInputs
  eigen,
  gtest,
  matio,
  ninja,
  # tests
  numpy,
  pybind11,
  pytestCheckHook,
  replaceVars,
  scikit-build-core,
  scipy,
}:
buildPythonPackage rec {
  pname = "piqp";
  version = "0.6.2";

  src = fetchFromGitHub {
    owner = "PREDICT-EPFL";
    repo = "piqp";
    tag = "v${version}";
    hash = "sha256-W9t7d+wV5WcphL54e6tpnKxiWFay9UrFmIRKsGk2yMM=";
  };

  patches = [
    (replaceVars ./use-nix-packages.patch {
      cpu_features_src = cpu_features.src;
    })
  ];

  buildInputs = [
    eigen
    gtest
    matio
  ];

  nativeCheckInputs = [
    numpy
    pytestCheckHook
    scipy
  ];

  build-system = [
    cmake
    ninja
    pybind11
    scikit-build-core
  ];

  dontUseCmakeConfigure = true;
  pyproject = true;
  pythonImportsCheck = [ "piqp" ];

  meta = {
    description = "Proximal Interior Point Quadratic Programming solver";
    homepage = "https://github.com/PREDICT-EPFL/piqp";
    changelog = "https://github.com/PREDICT-EPFL/piqp/releases/tag/v${version}";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ renesat ];
  };
}
