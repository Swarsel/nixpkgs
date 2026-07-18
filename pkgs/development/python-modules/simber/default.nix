{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  colorama,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "simber";
  version = "0.2.6";

  src = fetchFromGitHub {
    owner = "deepjyoti30";
    repo = "simber";
    tag = finalAttrs.version;
    hash = "sha256-kHoFZD7nhVxJu9MqePLkL7KTG2saPecY9238c/oeEco=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  __structuredAttrs = true;
  build-system = [ setuptools ];
  dependencies = [ colorama ];
  pyproject = true;
  pythonImportsCheck = [ "simber" ];

  meta = {
    description = "Simple, minimal and powerful logger for Python";
    homepage = "https://github.com/deepjyoti30/simber";
    changelog = "https://github.com/deepjyoti30/simber/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ j0hax ];
  };
})
