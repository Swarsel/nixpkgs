{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  freetype,
  numpy,
  packaging,
  pillow,
  pkgconfig,
  pytest,
  python,
  setuptools,
}:

buildPythonPackage rec {
  pname = "aggdraw";
  version = "1.4.1";

  src = fetchFromGitHub {
    owner = "pytroll";
    repo = "aggdraw";
    tag = "v${version}";
    hash = "sha256-rBasRGdlM6/NsUd8+KsgHoZMsWhAhneSWjTeZ/QQZZ8=";
  };

  buildInputs = [ freetype ];

  nativeCheckInputs = [
    numpy
    pillow
    pytest
  ];

  checkPhase = ''
    runHook preCheck
    ${python.interpreter} selftest.py
    runHook postCheck
  '';

  build-system = [
    packaging
    setuptools
    pkgconfig
  ];

  pyproject = true;
  pythonImportsCheck = [ "aggdraw" ];

  meta = {
    description = "High quality drawing interface for PIL";
    homepage = "https://github.com/pytroll/aggdraw";
    changelog = "https://github.com/pytroll/aggdraw/blob/${src.tag}CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ onny ];
  };
}
