{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  pcsclite,
  pkg-config,
  pytestCheckHook,
  setuptools,
  swig,
}:

buildPythonPackage rec {
  pname = "pyscard";
  version = "2.3.1";

  src = fetchFromGitHub {
    owner = "LudovicRousseau";
    repo = "pyscard";
    tag = version;
    hash = "sha256-MW/Cg7Ta/LdY/pOomsEecVIt62rc5qSAGjpJl4m+ruM=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'requires = ["setuptools","swig"]' 'requires = ["setuptools"]'
  ''
  + lib.optionalString (!stdenv.hostPlatform.isDarwin) ''
    substituteInPlace setup.py --replace-fail "pkg-config" "$PKG_CONFIG"
    substituteInPlace src/smartcard/scard/winscarddll.c \
      --replace-fail "libpcsclite.so.1" \
                "${lib.getLib pcsclite}/lib/libpcsclite${stdenv.hostPlatform.extensions.sharedLibrary}"
  '';

  nativeBuildInputs = [ swig ] ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [ pkg-config ];
  buildInputs = lib.optionals (!stdenv.hostPlatform.isDarwin) [ pcsclite ];
  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;

  meta = {
    description = "Smartcard library for python";
    homepage = "https://pyscard.sourceforge.io/";
    changelog = "https://github.com/LudovicRousseau/pyscard/releases/tag/${src.tag}";
    license = lib.licenses.lgpl21Plus;
    maintainers = with lib.maintainers; [ layus ];
  };
}
