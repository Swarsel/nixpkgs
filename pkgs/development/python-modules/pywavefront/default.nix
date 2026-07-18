{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  mock,
  pyglet,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "PyWavefront";
  version = "1.3.3";

  src = fetchFromGitHub {
    owner = "pywavefront";
    repo = "PyWavefront";
    rev = version;
    hash = "sha256-ci40L2opJ+NYYtaAeX1Y5pzkdK+loFspTriX/xv4KR8=";
  };

  nativeBuildInputs = [ setuptools ];

  nativeCheckInputs = [
    pytestCheckHook
    mock
  ];

  optional-dependencies.visualization = [ pyglet ];
  pyproject = true;
  pythonImportsCheck = [ "pywavefront" ];

  meta = {
    description = "Python library for importing Wavefront .obj files";
    homepage = "https://github.com/pywavefront/PyWavefront";
    changelog = "https://github.com/pywavefront/PyWavefront/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ pbsds ];
  };
}
