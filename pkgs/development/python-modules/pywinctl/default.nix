{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  ewmhlib,
  pymonctl,
  python-xlib,
  pywinbox,
  setuptools,
  typing-extensions,
}:

buildPythonPackage (finalAttrs: {
  pname = "pywinctl";
  version = "0.4.01";

  src = fetchFromGitHub {
    owner = "Kalmat";
    repo = "pywinctl";
    tag = "v${finalAttrs.version}";
    hash = "sha256-l9wUnEjOpKrjulruUX+AqQIjduDfX+iMmSv/V32jpdc=";
  };

  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    ewmhlib
    pymonctl
    pywinbox
    python-xlib
    typing-extensions
  ];

  pyproject = true;
  # requires x session (use ewmhlib)
  pythonImportsCheck = [ ];

  meta = {
    description = "Cross-Platform module to get info on and control windows on screen";
    homepage = "https://github.com/Kalmat/PyWinCtl";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ sigmanificient ];
  };
})
