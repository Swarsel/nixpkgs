{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  libx11,
  libxinerama,
  libxrandr,
  poetry-core,
  pyobjc-framework-Cocoa,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "screeninfo";
  version = "0.8.1";

  src = fetchFromGitHub {
    owner = "rr-";
    repo = "screeninfo";
    tag = version;
    hash = "sha256-TEy4wff0eRRkX98yK9054d33Tm6G6qWrd9Iv+ITcFmA=";
  };

  postPatch = lib.optionalString (stdenv.hostPlatform.isLinux) ''
    substituteInPlace screeninfo/enumerators/xinerama.py \
      --replace 'load_library("X11")' 'ctypes.cdll.LoadLibrary("${libx11}/lib/libX11.so")' \
      --replace 'load_library("Xinerama")' 'ctypes.cdll.LoadLibrary("${libxinerama}/lib/libXinerama.so")'
    substituteInPlace screeninfo/enumerators/xrandr.py \
      --replace 'load_library("X11")' 'ctypes.cdll.LoadLibrary("${libx11}/lib/libX11.so")' \
      --replace 'load_library("Xrandr")' 'ctypes.cdll.LoadLibrary("${libxrandr}/lib/libXrandr.so")'
  '';

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ poetry-core ];

  dependencies = lib.optionals (stdenv.hostPlatform.isDarwin) [
    pyobjc-framework-Cocoa
    cython
  ];

  disabledTestPaths = [
    # We don't have a screen
    "tests/test_screeninfo.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "screeninfo" ];

  meta = {
    description = "Fetch location and size of physical screens";
    homepage = "https://github.com/rr-/screeninfo";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nickhu ];
  };
}
