{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  charset-normalizer,
  pytestCheckHook,
  ruamel-yaml,
  setuptools,
  weblate-language-data,
}:

buildPythonPackage (finalAttrs: {
  pname = "translation-finder";
  version = "3.1";

  src = fetchFromGitHub {
    owner = "WeblateOrg";
    repo = "translation-finder";
    tag = finalAttrs.version;
    hash = "sha256-sRqn7K39R4A83USCng5wu14eKq4VqUp9tPzg8Qb8MOU=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    charset-normalizer
    ruamel-yaml
    weblate-language-data
  ];

  pyproject = true;
  pythonImportsCheck = [ "translation_finder" ];

  meta = {
    description = "Translation file finder for Weblate";
    homepage = "https://github.com/WeblateOrg/translation-finder";
    changelog = "https://github.com/WeblateOrg/translation-finder/blob/${finalAttrs.src.tag}/CHANGES.rst";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ erictapen ];
    mainProgram = "weblate-discover";
  };

})
