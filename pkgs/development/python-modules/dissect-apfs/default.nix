{
  lib,
  fetchFromGitHub,
  asn1crypto,
  buildPythonPackage,
  dissect-cstruct,
  dissect-fve,
  dissect-util,
  pycryptodome,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage (finalAttrs: {
  pname = "dissect-apfs";
  version = "1.1";

  src = fetchFromGitHub {
    owner = "fox-it";
    repo = "dissect.apfs";
    tag = finalAttrs.version;
    hash = "sha256-DCLaDXLE3WkWUNOhZpROaTxMrSF+of30G8D2ZXivJEg=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    asn1crypto
    dissect-fve
    dissect-cstruct
    dissect-util
    pycryptodome
  ];

  disabledTestPaths = [
    # Bad file
    "tests/test_apfs.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "dissect.apfs" ];

  meta = {
    description = "Dissect module implementing a parser for APFS";
    homepage = "https://github.com/fox-it/dissect.apfs";
    changelog = "https://github.com/fox-it/dissect.apfs/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ fab ];
  };
})
