{
  lib,
  buildPythonPackage,
  fetchPypi,
  fsspec,
  pathlib-abc,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "universal-pathlib";
  version = "0.3.8";

  src = fetchPypi {
    inherit version;
    hash = "sha256-6tK2W8o99uEcO3yzb8mEY0C8PC2071cTFVAmBCKwo+g=";
    pname = "universal_pathlib";
  };

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    fsspec
    pathlib-abc
  ];

  pyproject = true;
  pythonImportsCheck = [ "upath" ];

  meta = {
    description = "Pathlib api extended to use fsspec backends";
    homepage = "https://github.com/fsspec/universal_pathlib";
    changelog = "https://github.com/fsspec/universal_pathlib/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
