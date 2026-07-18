{
  lib,
  stdenv,
  buildPythonPackage,
  cacert,
  cached-property,
  cffi,
  fetchPypi,
  isPyPy,
  libgit2,
  pycparser,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pygit2";
  version = "1.19.3";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-pUPm1Ou0OCVWSTV1jcI053ABb+1nO4Q3DUaulYBViDE=";
  };

  buildInputs = [ libgit2 ];
  # Tests require certificates
  # https://github.com/NixOS/nixpkgs/pull/72544#issuecomment-582674047
  env.SSL_CERT_FILE = "${cacert}/etc/ssl/certs/ca-bundle.crt";

  preConfigure = lib.optionalString stdenv.hostPlatform.isDarwin ''
    export DYLD_LIBRARY_PATH="${libgit2}/lib"
  '';

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    cached-property
    pycparser
  ]
  ++ lib.optionals (!isPyPy) [ cffi ];

  disabledTestPaths = [
    # Disable tests that require networking
    "test/test_repository.py"
    "test/test_credentials.py"
    "test/test_submodule.py"
  ];

  propagatedNativeBuildInputs = lib.optionals (!isPyPy) [ cffi ];
  pyproject = true;
  pythonImportsCheck = [ "pygit2" ];

  meta = {
    description = "Set of Python bindings to the libgit2 shared library";
    homepage = "https://github.com/libgit2/pygit2";
    changelog = "https://github.com/libgit2/pygit2/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.gpl2Only;
    maintainers = [ ];
  };
}
