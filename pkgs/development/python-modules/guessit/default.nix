{
  lib,
  babelfish,
  buildPythonPackage,
  fetchPypi,
  py,
  pytest-benchmark,
  pytest-mock,
  pytestCheckHook,
  python-dateutil,
  pyyaml,
  rebulk,
}:

buildPythonPackage rec {
  pname = "guessit";
  version = "3.8.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-Zhn8u/mgUQ7IwsM3RMQlHK0FB7HVc9Bch13hftxe2+0=";
  };

  propagatedBuildInputs = [
    rebulk
    babelfish
    python-dateutil
  ];

  nativeCheckInputs = [
    py
    pytestCheckHook
    pytest-mock
    pytest-benchmark
    pyyaml
  ];

  format = "setuptools";
  pytestFlags = [ "--benchmark-disable" ];
  pythonImportsCheck = [ "guessit" ];

  meta = {
    description = "Python library that extracts as much information as possible from a video filename";
    homepage = "https://guessit-io.github.io/guessit/";
    changelog = "https://github.com/guessit-io/guessit/raw/v${version}/CHANGELOG.md";
    license = lib.licenses.lgpl3Only;
    maintainers = [ ];
    mainProgram = "guessit";
  };
}
