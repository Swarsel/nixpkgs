{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  libsodium,
  poetry-core,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "libnacl";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "saltstack";
    repo = "libnacl";
    rev = "v${version}";
    hash = "sha256-phECLGDcBfDi/r2y0eGtqgIX/hvirtBqO8UUvEJ66zo=";
  };

  postPatch =
    let
      soext = stdenv.hostPlatform.extensions.sharedLibrary;
    in
    ''
      substituteInPlace "./libnacl/__init__.py" \
        --replace \
          "l_path = ctypes.util.find_library('sodium')" \
          "l_path = None" \
        --replace \
          "ctypes.cdll.LoadLibrary('libsodium${soext}')" \
          "ctypes.cdll.LoadLibrary('${libsodium}/lib/libsodium${soext}')"
    '';

  nativeBuildInputs = [ poetry-core ];
  buildInputs = [ libsodium ];
  nativeCheckInputs = [ pytestCheckHook ];
  pyproject = true;
  pythonImportsCheck = [ "libnacl" ];

  meta = {
    description = "Python bindings for libsodium based on ctypes";
    homepage = "https://libnacl.readthedocs.io/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ xvapx ];
    platforms = lib.platforms.unix;
  };
}
