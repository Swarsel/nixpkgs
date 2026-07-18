{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # tests
  pytestCheckHook,
  # dependencies
  pyyaml,
  # build-system
  setuptools,
  unicode-rbnf,
}:

let
  pname = "hassil";
  version = "3.8.0";
in
buildPythonPackage rec {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "OHF-Voice";
    repo = "hassil";
    tag = "v${version}";
    hash = "sha256-b+ykT6P9yG8jZZN92K76uBaKTJpV6lkcqP3AAYbj3dU=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    pyyaml
    unicode-rbnf
  ];

  disabledTestPaths = [
    # infinite recursion with home-assistant.intents
    "tests/test_fuzzy.py"
  ];

  pyproject = true;

  meta = {
    description = "Intent parsing for Home Assistant";
    homepage = "https://github.com/OHF-Voice/hassil";
    changelog = "https://github.com/OHF-Voice/hassil/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    mainProgram = "hassil";
    teams = [ lib.teams.home-assistant ];
  };
}
