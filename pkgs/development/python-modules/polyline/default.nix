{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools,
  wheel,
}:

buildPythonPackage rec {
  pname = "polyline";
  version = "2.0.4";

  src = fetchFromGitHub {
    owner = "frederickjansen";
    repo = "polyline";
    tag = "v${version}";
    hash = "sha256-PaQLHz256ZZ+0PdSSeGM+rjubSnT4fQfpD1Uj3JfBt8=";
  };

  nativeBuildInputs = [
    setuptools
    wheel
  ];

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
  ];

  pyproject = true;
  pythonImportsCheck = [ "polyline" ];

  meta = {
    description = "Python implementation of Google's Encoded Polyline Algorithm Format";

    longDescription = ''
      polyline is a Python implementation of Google's Encoded Polyline Algorithm Format. It is
      essentially a port of https://github.com/mapbox/polyline.
    '';

    homepage = "https://github.com/frederickjansen/polyline";
    changelog = "https://github.com/frederickjansen/polyline/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ersin ];
  };
}
