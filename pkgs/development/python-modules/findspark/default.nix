{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage rec {
  pname = "findspark";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "minrk";
    repo = "findspark";
    tag = version;
    hash = "sha256-/+b1Pf+ySwlv6XP1wtHx1tx4WfYdu6GuxJVQkcX3MY8=";
  };

  # No tests
  doCheck = false;

  build-system = [
    setuptools
  ];

  pyproject = true;
  pythonImportsCheck = [ "findspark" ];

  meta = {
    description = "Find pyspark to make it importable";
    homepage = "https://github.com/minrk/findspark";
    changelog = "https://github.com/minrk/findspark/blob/${version}/CHANGELOG.md";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
}
