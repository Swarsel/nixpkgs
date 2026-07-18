{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flit-core,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "tinytag";
  version = "2.2.1";

  src = fetchFromGitHub {
    owner = "tinytag";
    repo = "tinytag";
    tag = finalAttrs.version;
    hash = "sha256-WrUpP2ItXUYsX5IB5K0YmG/N2mbAeaso6i0uUXkWHlY=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
    flit-core
  ];

  pyproject = true;
  pythonImportsCheck = [ "tinytag" ];

  meta = {
    description = "Read audio file metadata";
    homepage = "https://github.com/tinytag/tinytag";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sigmanificient ];
  };
})
