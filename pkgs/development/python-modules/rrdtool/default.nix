{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pkgs,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "rrdtool";
  version = "0.1.16";

  src = fetchFromGitHub {
    owner = "commx";
    repo = "python-rrdtool";
    tag = "v${version}";
    hash = "sha256-xBMyY2/lY16H7D0JX5BhgHV5afDKKDObPJnynZ4iZdI=";
  };

  buildInputs = [
    pkgs.rrdtool
  ];

  env.NIX_CFLAGS_COMPILE = toString [
    "-Wno-error=implicit-function-declaration"
    "-Wno-error=incompatible-pointer-types"
  ];

  nativeCheckInputs = [
    pytestCheckHook
  ];

  __darwinAllowLocalNetworking = true;

  build-system = [
    setuptools
  ];

  pyproject = true;
  pythonImportsCheck = [ "rrdtool" ];

  meta = {
    description = "Python bindings for rrdtool";
    homepage = "https://github.com/commx/python-rrdtool";
    license = lib.licenses.lgpl21Only;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
}
