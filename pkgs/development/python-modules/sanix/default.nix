{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "sanix";
  version = "1.0.6";

  src = fetchFromGitHub {
    owner = "tomaszsluszniak";
    repo = "sanix_py";
    tag = "v${version}";
    hash = "sha256-D2w3hmL8ym63liWOYdZS4ry3lJ0utbbYGagWoOTT1TQ=";
  };

  # Module has no tests
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ requests ];
  pyproject = true;
  pythonImportsCheck = [ "sanix" ];

  meta = {
    description = "Module to get measurements data from Sanix devices";
    homepage = "https://github.com/tomaszsluszniak/sanix_py";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
