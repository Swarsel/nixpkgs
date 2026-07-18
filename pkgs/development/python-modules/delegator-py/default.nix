{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pexpect,
  setuptools,
}:

buildPythonPackage rec {
  pname = "delegator-py";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "amitt001";
    repo = "delegator.py";
    tag = "v${version}";
    hash = "sha256-i9OZkXcDqrKnCFJBBxP8PrHxPGF7DEgZr91p+fuAyZ4=";
  };

  # no tests in github or pypi
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ pexpect ];
  pyproject = true;
  pythonImportsCheck = [ "delegator" ];

  meta = {
    description = "Subprocesses for Humans 2.0";
    homepage = "https://github.com/amitt001/delegator.py";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
