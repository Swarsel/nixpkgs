{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  python-xlib,
  setuptools,
  typing-extensions,
}:

buildPythonPackage (finalAttrs: {
  pname = "ewmhlib";
  version = "0.2";

  src = fetchFromGitHub {
    owner = "Kalmat";
    repo = "EWMHlib";
    tag = "v${finalAttrs.version}";
    hash = "sha256-NELOgUV8KuN+CqmoSbLYImguHlp8dyhGmJtoxJjOBkA=";
  };

  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    python-xlib
    typing-extensions
  ];

  pyproject = true;
  # requires x session (call to defaultDisplay.screen() on import)
  pythonImportsCheck = [ ];

  meta = {
    description = "Extended Window Manager Hints implementation in Python 3";
    homepage = "https://github.com/Kalmat/EWMHlib";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ sigmanificient ];
  };
})
