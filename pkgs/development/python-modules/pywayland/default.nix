{
  lib,
  buildPythonPackage,
  cffi,
  fetchPypi,
  pkg-config,
  pytestCheckHook,
  python,
  wayland,
  wayland-scanner,
}:

buildPythonPackage rec {
  pname = "pywayland";
  version = "0.4.18";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-WYreAng6rQWjKPZjtRtpTFq2i9XR4JJsDaPFISxWZTM=";
  };

  nativeBuildInputs = [ wayland-scanner ];
  buildInputs = [ wayland ];
  propagatedBuildInputs = [ cffi ];

  postBuild = ''
    ${python.pythonOnBuildForHost.interpreter} pywayland/ffi_build.py
  '';

  nativeCheckInputs = [ pytestCheckHook ];

  # Tests need this to create sockets
  preCheck = ''
    export XDG_RUNTIME_DIR="$PWD"
  '';

  depsBuildBuild = [ pkg-config ];
  format = "setuptools";
  propagatedNativeBuildInputs = [ cffi ];
  pythonImportsCheck = [ "pywayland" ];

  meta = {
    description = "Python bindings to wayland using cffi";
    homepage = "https://github.com/flacjacket/pywayland";
    license = lib.licenses.ncsa;
    maintainers = with lib.maintainers; [ chvp ];
    mainProgram = "pywayland-scanner";
  };
}
