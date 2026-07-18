{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  pyyaml,
  setuptools,
}:

buildPythonPackage rec {
  pname = "lnkparse3";
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "Matmaus";
    repo = "LnkParse3";
    tag = "v${version}";
    hash = "sha256-nTU6FMHM0hRwHBgszixZLArbhKKJmtwUXZC8ZW1KOvk=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  dependencies = [ pyyaml ];
  pyproject = true;
  pythonImportsCheck = [ "LnkParse3" ];

  meta = {
    description = "Windows Shortcut file (LNK) parser";
    homepage = "https://github.com/Matmaus/LnkParse3";
    changelog = "https://github.com/Matmaus/LnkParse3/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
