{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  packaging,
  pdm-backend,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "dep-logic";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "pdm-project";
    repo = "dep-logic";
    tag = finalAttrs.version;
    hash = "sha256-FfnRpWKsObt38b/2e3t4wgxCtEs6OiEAQfJqhD+hI7c=";
  };

  nativeBuildInputs = [ pdm-backend ];
  propagatedBuildInputs = [ packaging ];
  nativeCheckInputs = [ pytestCheckHook ];
  pyproject = true;
  pythonImportsCheck = [ "dep_logic" ];

  meta = {
    description = "Python dependency specifications supporting logical operations";
    homepage = "https://github.com/pdm-project/dep-logic";
    changelog = "https://github.com/pdm-project/dep-logic/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      tomasajt
      misilelab
    ];
  };
})
