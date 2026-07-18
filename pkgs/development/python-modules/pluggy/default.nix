{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  callPackage,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "pluggy";
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "pytest-dev";
    repo = "pluggy";
    tag = version;
    hash = "sha256-pkQjPJuSASWmzwzp9H/UTJBQDr2r2RiofxpF135lAgc=";
  };

  # To prevent infinite recursion with pytest
  doCheck = false;
  build-system = [ setuptools-scm ];
  pyproject = true;

  passthru.tests = {
    pytest = callPackage ./tests.nix { };
  };

  meta = {
    description = "Plugin and hook calling mechanisms for Python";
    homepage = "https://github.com/pytest-dev/pluggy";
    changelog = "https://github.com/pytest-dev/pluggy/blob/${src.rev}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
