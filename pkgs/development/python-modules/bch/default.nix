{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  click,
  click-log,
  paho-mqtt,
  pyaml,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "bch";
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "hardwario";
    repo = "bch-control-tool";
    tag = "v${finalAttrs.version}";
    hash = "sha256-/C+NbJ0RrWZ/scv/FiRBTh4h7u0xS4mHVDWQ0WwmlEY=";
  };

  postPatch = ''
    substituteInPlace bch/cli.py setup.py \
      --replace-fail "@@VERSION@@" "${finalAttrs.version}"
  '';

  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    click
    click-log
    paho-mqtt
    pyaml
  ];

  pyproject = true;
  pythonImportsCheck = [ "bch" ];

  meta = {
    description = "HARDWARIO Hub Control Tool";
    homepage = "https://github.com/hardwario/bch-control-tool";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ cynerd ];
    platforms = lib.platforms.linux;
    mainProgram = "bch";
  };
})
