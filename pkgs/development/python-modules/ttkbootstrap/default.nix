{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  pillow,
  setuptools,
}:

buildPythonPackage rec {
  pname = "ttkbootstrap";
  version = "1.20.4";

  src = fetchFromGitHub {
    owner = "israel-dryer";
    repo = "ttkbootstrap";
    tag = "v${version}";
    hash = "sha256-1w9DFeJEJjcCaRkgvQAddUafYKHlFZRIT/BnyAQAKW4=";
  };

  # As far as I can tell, all tests require a display and are not normal-ish pytests
  # but appear to just be python scripts that run demos of components?
  doCheck = false;

  build-system = [
    setuptools
  ];

  dependencies = [
    pillow
  ];

  pyproject = true;
  pythonRelaxDeps = [ "pillow" ];

  meta = {
    description = "Supercharged theme extension for tkinter inspired by Bootstrap";
    homepage = "https://github.com/israel-dryer/ttkbootstrap";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ e1mo ];
  };
}
