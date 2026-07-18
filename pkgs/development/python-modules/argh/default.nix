{
  lib,
  buildPythonPackage,
  fetchPypi,
  flit-core,
  iocapture,
  mock,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "argh";
  version = "0.31.3";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-8wAj2L4Uyl7msbPuq4KRUde72kZK4H3E3VNHkZxYkvk=";
  };

  patches = [
    # python3.14 introduced a breaking change which caused a test to fail. A
    # fix has been commited upstream in a pull request by the author, but has
    # since been kept unmerged
    # https://github.com/neithere/argh/pull/240
    ./pr240-699568ad-06-01-2025-test_integration.patch
  ];

  nativeBuildInputs = [ flit-core ];

  nativeCheckInputs = [
    iocapture
    mock
    pytestCheckHook
  ];

  pyproject = true;
  pythonImportsCheck = [ "argh" ];

  meta = {
    description = "Unobtrusive argparse wrapper with natural syntax";
    homepage = "https://github.com/neithere/argh";
    changelog = "https://github.com/neithere/argh/blob/v${version}/CHANGES";
    license = lib.licenses.lgpl3Plus;
    maintainers = [ ];
  };
}
