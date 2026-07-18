{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "opentimestamps-client";
  version = "0.7.2";

  src = fetchFromGitHub {
    owner = "opentimestamps";
    repo = "opentimestamps-client";
    tag = "opentimestamps-client-v${finalAttrs.version}";
    hash = "sha256-ny2svB8WcoUky8UfeilANo1DlS+f3o9RtV4YNmUwjJk=";
  };

  nativeCheckInputs = with python3.pkgs; [
    pytestCheckHook
  ];

  build-system = with python3.pkgs; [
    setuptools
  ];

  dependencies = with python3.pkgs; [
    appdirs
    gitpython
    opentimestamps
    pysocks
  ];

  pyproject = true;

  pythonImportsCheck = [
    "otsclient"
  ];

  meta = {
    description = "Command-line tool to create and verify OpenTimestamps proofs";
    homepage = "https://github.com/opentimestamps/opentimestamps-client";
    changelog = "https://github.com/opentimestamps/opentimestamps-client/releases/tag/opentimestamps-client-v${finalAttrs.version}";
    license = lib.licenses.lgpl3Only;
    maintainers = with lib.maintainers; [ erikarvstedt ];
    mainProgram = "ots";
  };
})
