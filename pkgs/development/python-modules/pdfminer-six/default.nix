{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  charset-normalizer,
  cryptography,
  ocrmypdf,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "pdfminer-six";
  version = "20260107";

  src = fetchFromGitHub {
    owner = "pdfminer";
    repo = "pdfminer.six";
    tag = version;
    hash = "sha256-spWDwPoBLdySysYblCWABIWtokOMoJdpYQ6qxX94wIE=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  postInstall = ''
    for file in "$out/bin/"*.py; do
      mv "$file" "''${file%.py}"
    done
  '';

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    charset-normalizer
    cryptography
  ];

  disabledTests = [
    # The binary file samples/contrib/issue-1004-indirect-mediabox.pdf is
    # stripped from fix-dereference-MediaBox.patch.
    "test_contrib_issue_1004_mediabox"
  ];

  pyproject = true;

  pythonImportsCheck = [
    "pdfminer"
    "pdfminer.high_level"
  ];

  passthru = {
    tests = {
      inherit ocrmypdf;
    };
  };

  meta = {
    description = "PDF parser and analyzer";
    homepage = "https://github.com/pdfminer/pdfminer.six";
    changelog = "https://github.com/pdfminer/pdfminer.six/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ psyanticy ];
  };
}
