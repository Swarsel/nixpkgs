{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "jaconv";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "ikegami-yukino";
    repo = "jaconv";
    tag = "v${version}";
    hash = "sha256-43sziwJ/SDdpLHJyGXyI5nXEofbos2W+NV7DlOpWWa8=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "jaconv" ];

  meta = {
    description = "Python Japanese character interconverter for Hiragana, Katakana, Hankaku and Zenkaku";
    homepage = "https://github.com/ikegami-yukino/jaconv";
    changelog = "https://github.com/ikegami-yukino/jaconv/blob/${src.tag}/CHANGES.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
