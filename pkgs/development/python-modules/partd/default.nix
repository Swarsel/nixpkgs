{
  lib,
  fetchFromGitHub,
  # optional-dependencies
  blosc2,
  buildPythonPackage,
  # dependencies
  locket,
  numpy,
  pandas,
  # tests
  pytestCheckHook,
  pyzmq,
  # build-system
  setuptools,
  toolz,
  versioneer,
}:

buildPythonPackage rec {
  pname = "partd";
  version = "1.4.2";

  src = fetchFromGitHub {
    owner = "dask";
    repo = "partd";
    tag = version;
    hash = "sha256-GtIo6n87TmM5aRgtRyxhhXXAINpPCFbjZ/sQz/vkcoA=";
  };

  nativeBuildInputs = [
    setuptools
    versioneer
  ];

  propagatedBuildInputs = [
    locket
    toolz
  ];

  nativeCheckInputs = [ pytestCheckHook ];

  optional-dependencies = {
    complete = [
      blosc2
      numpy
      pandas
      pyzmq
    ];
  };

  pyproject = true;

  meta = {
    description = "Appendable key-value storage";
    homepage = "https://github.com/dask/partd/";
    license = with lib.licenses; [ bsd3 ];
  };
}
