{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "python-mpv-jsonipc";
  version = "1.2.2";

  src = fetchFromGitHub {
    owner = "iwalton3";
    repo = "python-mpv-jsonipc";
    tag = "v${finalAttrs.version}";
    hash = "sha256-9QfGsJW08YqATP4+G3bADkjxHoauSF7BmcsIi56fBKI=";
  };

  # 'mpv-jsonipc' does not have any tests
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "python_mpv_jsonipc" ];

  meta = {
    description = "Python API to MPV using JSON IPC";
    homepage = "https://github.com/iwalton3/python-mpv-jsonipc";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
})
