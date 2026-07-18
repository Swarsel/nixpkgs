{
  lib,
  buildPythonPackage,
  fetchPypi,
  # dependencies
  fsspec,
  numpy,
  packaging,
  psutil,
  pyre-extensions,
  # build-system
  setuptools,
  tabulate,
  tensorboard,
  torch,
  tqdm,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "torchtnt";
  version = "0.2.4";

  # no tag / releases on github
  src = fetchPypi {
    inherit pname version;
    hash = "sha256-Js9OcYllr8KT52FYtHKDciBVvPeelNDmfnC12/YcDJs=";
  };

  # requirements.txt is not included in Pypi archive
  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail 'read_requirements("requirements.txt")' "[]" \
      --replace-fail 'read_requirements("dev-requirements.txt")' "[]"
  '';

  # Tests are not included in Pypi archive
  doCheck = false;

  build-system = [
    setuptools
  ];

  dependencies = [
    fsspec
    numpy
    packaging
    psutil
    pyre-extensions
    setuptools
    tabulate
    tensorboard
    torch
    tqdm
    typing-extensions
  ];

  pyproject = true;

  pythonImportsCheck = [
    "torchtnt"
  ];

  meta = {
    description = "Lightweight library for PyTorch training tools and utilities";
    homepage = "https://github.com/pytorch/tnt";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ nim65s ];
  };
}
