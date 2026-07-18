{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage rec {
  pname = "fiscalyear";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "adamjstewart";
    repo = "fiscalyear";
    tag = "v${version}";
    hash = "sha256-2wejJRTmVHWiM8LoodyaOyMbMqCx5It6JHCQUWpGsxs=";
  };

  # upstream has no tests
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "fiscalyear" ];

  meta = {
    description = "Utilities for managing the fiscal calendar";
    homepage = "https://github.com/adamjstewart/fiscalyear";
    changelog = "https://github.com/adamjstewart/fiscalyear/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.dotlambda ];
  };
}
