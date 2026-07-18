{
  lib,
  buildPythonPackage,
  fetchPypi,

  # build-system
  hatch-vcs,
  hatchling,

  # dependencies
  requests,
}:

buildPythonPackage (finalAttrs: {
  pname = "pyannoteai-sdk";
  version = "0.4.0";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-+9reButUNHN0rPEGmLjJwLzbWS+DOckMWhb6RB6oz50=";
    pname = "pyannoteai_sdk";
  };

  # No tests (at least in the Pypi archive)
  doCheck = false;

  build-system = [
    hatch-vcs
    hatchling
  ];

  dependencies = [
    requests
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyannoteai.sdk" ];

  meta = {
    description = "Official pyannoteAI Python SDK";
    homepage = "https://pypi.org/project/pyannoteai-sdk";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
