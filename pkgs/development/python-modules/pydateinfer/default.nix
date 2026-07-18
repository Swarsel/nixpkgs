{
  lib,
  fetchFromGitHub,
  argparse,
  buildPythonPackage,
  pytz,
  pyyaml,
  unittestCheckHook,
}:

buildPythonPackage rec {
  pname = "pydateinfer";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "wdm0006";
    repo = "dateinfer";
    rev = "${version},"; # yes the comma is required, this is correct name of git tag
    hash = "sha256-0gy7wfT/uMTmpdIF2OPGVeUh+4yqJSI2Ebif0Lf/DLM=";
  };

  propagatedBuildInputs = [ pytz ];

  nativeCheckInputs = [
    unittestCheckHook
    pyyaml
    argparse
  ];

  preCheck = "cd dateinfer";
  format = "setuptools";
  pythonImportsCheck = [ "dateinfer" ];

  meta = {
    description = "Infers date format from examples";
    homepage = "https://pypi.org/project/pydateinfer/";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
