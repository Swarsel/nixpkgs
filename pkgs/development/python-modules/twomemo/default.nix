{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  doubleratchet,
  omemo,
  protobuf,
  setuptools,
  typing-extensions,
  x3dh,
  xeddsa,
  xmlschema,
}:
buildPythonPackage rec {
  pname = "twomemo";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "Syndace";
    repo = "python-twomemo";
    tag = "v${version}";
    hash = "sha256-OVZmssJuufKwyEd8q25h9AcDprZZPm588khncBqTaJA=";
  };

  strictDeps = true;
  build-system = [ setuptools ];

  dependencies = [
    doubleratchet
    omemo
    x3dh
    xeddsa
    protobuf
    typing-extensions
  ];

  optional-dependencies.xml = [
    xmlschema
  ];

  pyproject = true;

  pythonImportsCheck = [
    "twomemo"
  ];

  meta = {
    description = "Backend implementation of the urn:xmpp:omemo:2 namespace for python-omemo";
    homepage = "https://github.com/Syndace/python-twomemo";
    changelog = "https://github.com/Syndace/python-twomemo/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ themadbit ];
    teams = with lib.teams; [ ngi ];
  };
}
