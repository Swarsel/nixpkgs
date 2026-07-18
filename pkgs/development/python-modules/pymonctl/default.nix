{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  ewmhlib,
  python-xlib,
  setuptools,
  typing-extensions,
}:

buildPythonPackage (finalAttrs: {
  pname = "pymonctl";
  version = "0.92";

  src = fetchFromGitHub {
    owner = "Kalmat";
    repo = "PyMonCtl";
    tag = "v${finalAttrs.version}";
    hash = "sha256-eFB+HqYBud836VNEA8q8o1KQKA+GHwSC0YfU1KCbDXw=";
  };

  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    ewmhlib
    python-xlib
    typing-extensions
  ];

  pyproject = true;
  # requires x session (use ewmhlib)
  pythonImportsCheck = [ ];

  meta = {
    description = "Cross-Platform toolkit to get info on and control monitors connected";
    homepage = "https://github.com/Kalmat/PyMonCtl";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ sigmanificient ];
    broken = stdenv.hostPlatform.isDarwin;
  };
})
