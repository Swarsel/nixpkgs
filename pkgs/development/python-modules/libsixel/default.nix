{
  lib,
  stdenv,
  buildPythonPackage,
  libsixel,
}:

buildPythonPackage rec {
  pname = "libsixel";
  version = libsixel.version;
  src = libsixel.src;
  # no tests
  doCheck = false;
  format = "setuptools";

  prePatch = ''
    substituteInPlace libsixel/__init__.py --replace \
      'from ctypes.util import find_library' \
      'find_library = lambda _x: "${lib.getLib libsixel}/lib/libsixel${stdenv.hostPlatform.extensions.sharedLibrary}"'
  '';

  pythonImportsCheck = [ "libsixel" ];
  sourceRoot = "${src.name}/python";

  meta = {
    description = "SIXEL graphics encoder/decoder implementation";
    homepage = "https://github.com/libsixel/libsixel";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ rmcgibbo ];
  };
}
