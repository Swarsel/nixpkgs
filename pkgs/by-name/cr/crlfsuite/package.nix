{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "crlfsuite";
  version = "2.5.2";

  src = fetchFromGitHub {
    owner = "Raghavd3v";
    repo = "CRLFsuite";
    tag = "v${finalAttrs.version}";
    sha256 = "sha256-mK20PbVGhTEjhY5L6coCzSMIrG/PHHmNq30ZoJEs6uI=";
  };

  # No tests present
  doCheck = false;

  build-system = with python3.pkgs; [
    setuptools
  ];

  dependencies = with python3.pkgs; [
    colorama
    requests
  ];

  pyproject = true;

  pythonImportsCheck = [
    "crlfsuite"
  ];

  meta = {
    description = "CRLF injection (HTTP Response Splitting) scanner";
    homepage = "https://github.com/Raghavd3v/CRLFsuite";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      fab
    ];

    mainProgram = "crlfsuite";
  };
})
