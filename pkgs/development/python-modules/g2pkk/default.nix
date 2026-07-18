{
  lib,
  buildPythonPackage,
  fetchPypi,
  jamo,
  nltk,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "g2pkk";
  version = "0.1.2";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-YarV1Btn1x3Sm4Vw/JDSyJy3ZJMXAQHZJJJklSG0R+Q=";
  };

  doCheck = false;
  __structuredAttrs = true;

  build-system = [
    setuptools
  ];

  dependencies = [
    jamo
    nltk
  ];

  pyproject = true;
  pythonImportsCheck = [ "g2pkk" ];

  meta = {
    description = "Cross-platform g2p for Korean";
    homepage = "https://github.com/harmlessman/g2pkk";
    license = lib.licenses.asl20;
    teams = [ lib.teams.tts ];
  };
})
