{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  colormath2,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "spectra";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "jsvine";
    repo = "spectra";
    tag = "v${version}";
    hash = "sha256-PS5p9IR3v6+Up5Fcq8mhkprVgXigD6PZUF4/6hbv7NI=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ];

  build-system = [
    setuptools
  ];

  dependencies = [ colormath2 ];
  pyproject = true;

  meta = {
    description = "Python library that makes color math, color scales, and color-space conversion easy";
    homepage = "https://github.com/jsvine/spectra";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ apraga ];
  };
}
