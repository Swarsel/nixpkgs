{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # codegen
  hassil,
  jinja2,
  # tests
  pytest-xdist,
  pytestCheckHook,
  python,
  pyyaml,
  regex,
  # build-system
  setuptools,
  voluptuous,
}:

buildPythonPackage (finalAttrs: {
  pname = "home-assistant-intents";
  version = "2026.6.24";

  src = fetchFromGitHub {
    owner = "OHF-Voice";
    repo = "intents-package";
    tag = finalAttrs.version;
    hash = "sha256-fuVS+s3l/oStgrRdeLzHrzCr9cmFesq6sYV8EgNNsIo=";
    fetchSubmodules = true;
  };

  nativeCheckInputs = [
    pytest-xdist
    pytestCheckHook
  ];

  postInstall = ''
    # https://github.com/OHF-Voice/intents-package/blob/main/script/package#L23-L24
    PACKAGE_DIR=$out/${python.sitePackages}/home_assistant_intents
    ${python.pythonOnBuildForHost.interpreter} script/merged_output.py $PACKAGE_DIR/data
    ${python.pythonOnBuildForHost.interpreter} script/write_languages.py $PACKAGE_DIR/data > $PACKAGE_DIR/languages.py
  '';

  build-system = [
    setuptools

    # build-time codegen; https://github.com/home-assistant/intents/blob/main/requirements.txt#L1-L5
    hassil
    pyyaml
    voluptuous
    regex
    jinja2
  ];

  enabledTestPaths = [
    "intents/tests"
  ];

  pyproject = true;

  meta = {
    description = "Intents to be used with Home Assistant";
    homepage = "https://github.com/OHF-Voice/intents-package";
    changelog = "https://github.com/OHF-Voice/intents-package/releases/tag/${finalAttrs.src.tag}";
    # https://github.com/OHF-Voice/intents-package/issues/12
    license = lib.licenses.cc-by-40;
    teams = [ lib.teams.home-assistant ];
  };
})
