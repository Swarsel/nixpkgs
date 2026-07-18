{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  poetry-core,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "gamble";
  version = "0.14.0";

  src = fetchFromGitHub {
    owner = "jpetrucciani";
    repo = "gamble";
    tag = version;
    hash = "sha256-vzaY5gJ0Ou2ArUJ0kuTWzTeLfiRDhUt/Hxpns9rFiDk=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ poetry-core ];
  pyproject = true;
  pythonImportsCheck = [ "gamble" ];

  meta = {
    description = "Collection of gambling classes/tools";
    homepage = "https://github.com/jpetrucciani/gamble";
    changelog = "https://github.com/jpetrucciani/gamble/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jpetrucciani ];
  };
}
