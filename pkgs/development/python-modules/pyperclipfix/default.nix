{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage {
  pname = "pyperclipfix";
  version = "1.9.4-unstable-2024-01-23";

  src = fetchFromGitHub {
    owner = "AuroraWright";
    repo = "pyperclipfix";
    rev = "8c6c61de35b44ddbc927b37ade5579825db40826"; # no tags
    hash = "sha256-sREtSNEMj0Q+XWQsJu/7u9M1UdiocDq/YkrCPGRLhHA=";
  };

  # test file is trying to import pyperclip
  doCheck = false;
  nativeCheckInputs = [ pytestCheckHook ];

  preCheck = ''
    substituteInPlace tests/test_pyperclip.py \
      --replace-fail "pyperclip" "pyperclipfix"
  '';

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "pyperclipfix" ];

  meta = {
    description = "Cross-platform clipboard module with various fixes";
    homepage = "https://github.com/AuroraWright/pyperclipfix";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ sigmanificient ];
  };
}
