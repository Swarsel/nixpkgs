{
  lib,
  stdenv,
  buildPythonPackage,
  fetchPypi,
  pkgs,
  pytestCheckHook,
  setuptools,
}:

let
  libsecp256k1_name =
    if stdenv.hostPlatform.isLinux then
      "libsecp256k1.so.{v}"
    else if stdenv.hostPlatform.isDarwin then
      "libsecp256k1.{v}.dylib"
    else
      "libsecp256k1${stdenv.hostPlatform.extensions.sharedLibrary}";
in
buildPythonPackage rec {
  pname = "electrum-ecc";
  version = "0.0.6";

  src = fetchPypi {
    inherit version;
    hash = "sha256-Y2DHH7CLUdgKRV6TjxJrpMeQvnS6ImRh1U16OqaJC4k=";
    pname = "electrum_ecc";
  };

  postPatch = ''
    # remove bundled libsecp256k1
    rm -rf libsecp256k1/
    # use the system library instead
    substituteInPlace ./src/electrum_ecc/ecc_fast.py \
      --replace-fail ${libsecp256k1_name} ${pkgs.secp256k1}/lib/libsecp256k1${stdenv.hostPlatform.extensions.sharedLibrary}
  '';

  env = {
    # Prevent compilation of the C extension as we use the system library instead.
    ELECTRUM_ECC_DONT_COMPILE = "1";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "electrum_ecc" ];

  meta = {
    description = "Pure python ctypes wrapper for libsecp256k1";
    homepage = "https://github.com/spesmilo/electrum-ecc";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
