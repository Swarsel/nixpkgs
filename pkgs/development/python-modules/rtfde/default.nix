{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  lark,
  lxml,
  oletools,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "rtfde";
  version = "0.1.2.2";

  src = fetchFromGitHub {
    owner = "seamustuohy";
    repo = "RTFDE";
    tag = finalAttrs.version;
    hash = "sha256-1yjxp6N07I9kwFRtgsLo9UPSG4FU+ic1tNm6U/xWk74=";
  };

  nativeCheckInputs = [
    lxml
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    lark
    oletools
  ];

  disabledTests = [
    # Malformed encapsulated RTF discovered
    "test_encoded_bytes_stay_encoded_character"
  ];

  pyproject = true;
  pythonImportsCheck = [ "RTFDE" ];
  pythonRelaxDeps = [ "lark" ];

  meta = {
    description = "Library for extracting encapsulated HTML and plain text content from the RTF bodies";
    homepage = "https://github.com/seamustuohy/RTFDE";
    changelog = "https://github.com/seamustuohy/RTFDE/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.lgpl3Only;
    maintainers = with lib.maintainers; [ fab ];
  };
})
