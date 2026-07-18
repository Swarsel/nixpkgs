{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "python-iso639";
  version = "2026.4.20";

  src = fetchFromGitHub {
    owner = "jacksonllee";
    repo = "iso639";
    tag = "v${finalAttrs.version}";
    hash = "sha256-aXckFcWG8zcP9GELTT5eHnQzklAYG70LyX34fhVGdTo=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "iso639" ];

  meta = {
    description = "ISO 639 language codes, names, and other associated information";
    homepage = "https://github.com/jacksonllee/iso639";
    changelog = "https://github.com/jacksonllee/iso639/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
})
