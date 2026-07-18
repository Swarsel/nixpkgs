{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  py,
  pytest,
  # build inputs
  tblib,
}:
let
  pname = "pytest-parallel";
  version = "0.1.1";
in
buildPythonPackage {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "kevlened";
    repo = "pytest-parallel";
    tag = version;
    hash = "sha256-ddpoWBTf7Zor569p6uOMjHSTx3Qa551f4mSwyTLDdBU=";
  };

  propagatedBuildInputs = [
    tblib
    pytest
    py
  ];

  format = "setuptools";

  meta = {
    description = "Pytest plugin for parallel and concurrent testing";
    homepage = "https://github.com/kevlened/pytest-parallelt";
    changelog = "https://github.com/kevlened/pytest-parallel/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ happysalada ];
  };
}
