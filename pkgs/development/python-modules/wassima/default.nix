{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "wassima";
  version = "2.1.2";

  src = fetchFromGitHub {
    owner = "jawah";
    repo = "wassima";
    tag = finalAttrs.version;
    hash = "sha256-19y1dohS1WikfxRGOrgIqwdfBdGe7MDo9MTSXnNjfWA=";
  };

  # tests connect to the internet
  doCheck = false;

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [ hatchling ];
  pyproject = true;
  pythonImportsCheck = [ "wassima" ];

  meta = {
    description = "Access your OS root certificates with utmost ease";
    homepage = "https://github.com/jawah/wassima";
    changelog = "https://github.com/jawah/wassima/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
})
