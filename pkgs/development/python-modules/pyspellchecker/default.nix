{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pyspellchecker";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "barrust";
    repo = "pyspellchecker";
    tag = "v${version}";
    hash = "sha256-Ui1IPqvVqf7scMg+B1KmI5jWrHSsuaW6sCoWeiF2oMI=";
  };

  nativeBuildInputs = [ setuptools ];
  nativeCheckInputs = [ pytestCheckHook ];
  pyproject = true;

  meta = {
    description = "Pure python spell checking";
    homepage = "https://github.com/barrust/pyspellchecker";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ zendo ];
  };
}
