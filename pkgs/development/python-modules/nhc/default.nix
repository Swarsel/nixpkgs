{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage rec {
  pname = "nhc";
  version = "0.8.1";

  src = fetchFromGitHub {
    owner = "vandeurenglenn";
    repo = "nhc";
    tag = "v${version}";
    hash = "sha256-qSNpq21lEKZ0VVS2rN9OoDQymVGnqGCz6oeXjV1I20k=";
  };

  # upstream has no test
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "nhc" ];

  meta = {
    description = "SDK for Niko Home Control";
    homepage = "https://github.com/vandeurenglenn/nhc";
    changelog = "https://github.com/VandeurenGlenn/nhc/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
