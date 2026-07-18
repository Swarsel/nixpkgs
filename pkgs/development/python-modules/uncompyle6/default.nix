{
  lib,
  buildPythonPackage,
  fetchPypi,
  fetchpatch,
  hypothesis,
  pytestCheckHook,
  setuptools,
  six,
  spark-parser,
  xdis,
}:

buildPythonPackage rec {
  pname = "uncompyle6";
  version = "3.9.3";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-eLdk1MhDsEVfs5223rQhpI1dPruEZTe6ZESv4QfE68E=";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-z11AKF5RC4gibUbH3hI2Rsbn8VDg49SnKfqV4TuVnjc=";
      name = "support-xdis-6.3-api.patch";
      url = "https://github.com/rocky/python-uncompyle6/commit/62372825c62044428c29a9ce86b5afa81e93c5ae.patch";
    })
  ];

  # No tests are provided for versions past 3.8,
  # as the project only targets bytecode of versions <= 3.8
  doCheck = false;

  nativeCheckInputs = [
    pytestCheckHook
    hypothesis
    six
  ];

  build-system = [ setuptools ];

  dependencies = [
    spark-parser
    xdis
  ];

  pyproject = true;
  pythonRelaxDeps = [ "spark-parser" ];

  meta = {
    description = "Bytecode decompiler for Python versions 3.8 and below";
    homepage = "https://github.com/rocky/python-uncompyle6";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ melvyn2 ];
  };
}
