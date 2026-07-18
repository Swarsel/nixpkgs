{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  djvulibre,
  ghostscript_headless,
  pkg-config,
  setuptools,
  unittestCheckHook,
}:

buildPythonPackage rec {
  pname = "python-djvulibre";
  version = "0.9.3";

  src = fetchFromGitHub {
    owner = "FriedrichFroebel";
    repo = "python-djvulibre";
    tag = version;
    hash = "sha256-ntDRntNxVchZm+i+qBbiZlfHAXJRKMin9Hi+BoJQjTM=";
  };

  nativeCheckInputs = [ unittestCheckHook ];

  preCheck = ''
    rm -rf djvu
    rm -rf tests/examples
  '';

  build-system = [
    cython
    djvulibre
    ghostscript_headless
    pkg-config
    setuptools
  ];

  dependencies = [
    djvulibre
    ghostscript_headless
  ];

  pyproject = true;

  unittestFlagsArray = [
    "tests"
    "-v"
  ];

  meta = {
    description = "Python support for the DjVu image format";
    homepage = "https://github.com/FriedrichFroebel/python-djvulibre";
    changelog = "https://github.com/FriedrichFroebel/python-djvulibre/releases/tag/${src.tag}";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ dansbandit ];
  };
}
