{
  lib,
  fetchFromGitHub,
  nix-update-script,
  python3Packages,
  versionCheckHook,
}:
let
  version = "1.2.2";
in
python3Packages.buildPythonApplication {
  inherit version;
  pname = "letsdns";

  src = fetchFromGitHub {
    owner = "LetsDNS";
    repo = "letsdns";
    tag = version;
    hash = "sha256-tSr1cjgDq7h9pCP2NXG0MegRYsdvTiG8lSedoTRvp6g=";
  };

  env = {
    UNITTEST_CONF = "tests/citest.conf";
  };

  nativeCheckInputs = [
    python3Packages.pytestCheckHook
    versionCheckHook
  ];

  build-system = [
    python3Packages.setuptools
  ];

  dependencies = with python3Packages; [
    cryptography
    dnspython
    requests
  ];

  disabledTestPaths = [
    # These tests require upstream certificates
    "tests/test_action.py"
  ];

  pyproject = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Manage DANE TLSA records in DNS servers";
    homepage = "https://www.letsdns.de/";
    changelog = "https://github.com/LetsDNS/letsdns/releases/tag/${version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ rseichter ];
    mainProgram = "letsdns";
    downloadPage = "https://github.com/LetsDNS/letsdns";
  };
}
