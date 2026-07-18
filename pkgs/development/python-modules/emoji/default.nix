{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "emoji";
  version = "2.15.0";

  src = fetchFromGitHub {
    owner = "carpedm20";
    repo = "emoji";
    tag = "v${version}";
    hash = "sha256-YHf5UIxbdBS4JEPrD4BWE+wzYkzAboMpGmuMbOgR7s0=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  disabledTests = [ "test_emojize_name_only" ];
  pyproject = true;
  pythonImportsCheck = [ "emoji" ];

  meta = {
    description = "Emoji for Python";
    homepage = "https://github.com/carpedm20/emoji/";
    changelog = "https://github.com/carpedm20/emoji/blob/${src.tag}/CHANGES.md";
    license = lib.licenses.bsd3;
    maintainers = [ ];
  };
}
