{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  feh,
  imagemagick,
  pytestCheckHook,
  setuptools,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "pywal16";
  version = "3.8.15";

  src = fetchFromGitHub {
    owner = "eylles";
    repo = "pywal16";
    tag = finalAttrs.version;
    hash = "sha256-2KlVeOrF/nfRZk12gthDJ08xNvVbP5em3eXPMudo1Vs=";
  };

  nativeCheckInputs = [
    feh
    imagemagick
    pytestCheckHook
    writableTmpDirAsHomeHook
  ];

  build-system = [ setuptools ];
  pyproject = true;

  meta = {
    description = "Generate and change colorschemes on the fly. A 'wal' rewrite in Python 3";
    homepage = "https://github.com/eylles/pywal16";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ Fresheyeball ];
    mainProgram = "wal";
  };
})
