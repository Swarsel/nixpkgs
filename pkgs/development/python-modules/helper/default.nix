{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  mock,
  pytestCheckHook,
  pyyaml,
}:

buildPythonPackage rec {
  pname = "helper";
  version = "2.5.0";

  src = fetchFromGitHub {
    owner = "gmr";
    repo = "helper";
    rev = version;
    sha256 = "0zypjv8rncvrsgl200v7d3bn08gs48dwqvgamfqv71h07cj6zngp";
  };

  propagatedBuildInputs = [ pyyaml ];

  nativeCheckInputs = [
    pytestCheckHook
    mock
  ];

  format = "setuptools";

  pythonImportsCheck = [
    "helper"
    "helper.config"
  ];

  meta = {
    description = "Development library for quickly writing configurable applications and daemons";
    homepage = "https://helper.readthedocs.org/";
    license = lib.licenses.bsd3;
  };
}
