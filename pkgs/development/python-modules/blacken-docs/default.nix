{
  lib,
  fetchFromGitHub,
  black,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "blacken-docs";
  version = "1.20.0";

  src = fetchFromGitHub {
    owner = "adamchainz";
    repo = "blacken-docs";
    tag = version;
    hash = "sha256-A8hSpywuhdS+RNm3QQJ11ofWrYZgiOFRwIoD3mlwc4k=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  dependencies = [ black ];
  pyproject = true;

  meta = {
    description = "Run Black on Python code blocks in documentation files";
    homepage = "https://github.com/adamchainz/blacken-docs";
    changelog = "https://github.com/adamchainz/blacken-docs/blob/${src.rev}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.l0b0 ];
    mainProgram = "blacken-docs";
  };
}
