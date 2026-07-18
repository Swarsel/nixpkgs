{
  lib,
  fetchFromGitHub,
  banal,
  buildPythonPackage,
  chardet,
  charset-normalizer,
  hatchling,
  pyicu,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "normality";
  version = "3.1.0";

  src = fetchFromGitHub {
    owner = "pudo";
    repo = "normality";
    tag = finalAttrs.version;
    hash = "sha256-A3uaGAa3SQSNM73h/OlwvMc5FKbZvdsE6S07C/sEbSc=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ hatchling ];

  dependencies = [
    charset-normalizer
    chardet
    banal
    pyicu
  ];

  pyproject = true;
  pythonImportsCheck = [ "normality" ];

  meta = {
    description = "Micro-library to normalize text strings";
    homepage = "https://github.com/pudo/normality";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sigmanificient ];
  };
})
