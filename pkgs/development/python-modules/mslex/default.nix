{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytest,
  setuptools,
}:

buildPythonPackage rec {
  pname = "mslex";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "smoofra";
    repo = "mslex";
    tag = "v${version}";
    hash = "sha256-vr36OTCTJFZRXlkeGgN4UOlH+6uAkMvqTEO9qL8X98w=";
  };

  nativeCheckInputs = [
    pytest
  ];

  build-system = [
    setuptools
  ];

  pyproject = true; # fallback to setup.py if pyproject.toml is not present

  pythonImportsCheck = [
    "mslex"
  ];

  meta = {
    description = "Like shlex, but for windows";
    homepage = "https://github.com/smoofra/mslex";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ yzx9 ];
  };
}
