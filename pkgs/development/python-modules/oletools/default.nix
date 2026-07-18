{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  colorclass,
  easygui,
  msoffcrypto-tool,
  olefile,
  pcodedmp,
  pyparsing,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "oletools";
  version = "0.60.2";

  src = fetchFromGitHub {
    owner = "decalage2";
    repo = "oletools";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ons1VeWStxUZw2CPpnX9p5I3Q7cMhi34JU8TeuUDt+Y=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    colorclass
    easygui
    msoffcrypto-tool
    olefile
    pcodedmp
    pyparsing
  ];

  disabledTests = [
    # Test fails with AssertionError: Tuples differ: ('MS Word 2007+...
    "test_all"
    "test_xlm"
    # AssertionError: Found "warn" in output...
    "test_empty_behaviour"
    "test_rtf_behaviour"
    "test_text_behaviour"
  ];

  format = "setuptools";
  pythonImportsCheck = [ "oletools" ];
  pythonRelaxDeps = [ "pyparsing" ];

  meta = {
    description = "Module to analyze MS OLE2 files and MS Office documents";
    homepage = "https://github.com/decalage2/oletools";
    changelog = "https://github.com/decalage2/oletools/releases/tag/${finalAttrs.src.tag}";

    license = with lib.licenses; [
      bsd2 # and
      mit
    ];

    maintainers = with lib.maintainers; [ fab ];
  };
})
