{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "housekeeping";
  version = "1.1";

  src = fetchFromGitHub {
    owner = "beanbaginc";
    repo = "housekeeping";
    tag = "release-${version}";
    hash = "sha256-hRWZSRoXscjkUm0NUpkM6pKEdoirN6ZmpjWlNgoyCVY=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  dependencies = [ typing-extensions ];
  pyproject = true;
  pythonImportsCheck = [ "housekeeping" ];

  meta = {
    description = "Reusable deprecation helpers for Python projects";
    homepage = "https://github.com/beanbaginc/housekeeping";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
