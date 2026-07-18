{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  libsodium,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pysodium";
  version = "0.7.18";

  src = fetchFromGitHub {
    owner = "stef";
    repo = "pysodium";
    tag = "v${version}";
    hash = "sha256-F2215AAI8UIvn6UbaJ/YxI4ZolCzlwY6nS5IafTs+i4=";
  };

  postPatch =
    let
      soext = stdenv.hostPlatform.extensions.sharedLibrary;
    in
    ''
      substituteInPlace ./pysodium/__init__.py --replace-fail \
        "ctypes.util.find_library('sodium') or ctypes.util.find_library('libsodium')" "'${libsodium}/lib/libsodium${soext}'"
    '';

  buildInputs = [ libsodium ];
  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "pysodium" ];

  meta = {
    description = "Wrapper for libsodium providing high level crypto primitives";
    homepage = "https://github.com/stef/pysodium";
    changelog = "https://github.com/stef/pysodium/releases/tag/v${version}";
    license = lib.licenses.bsd2;
    maintainers = [ lib.maintainers.ethancedwards8 ];
  };
}
