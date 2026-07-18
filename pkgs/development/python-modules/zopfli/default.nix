{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  setuptools-scm,
  zopfli,
}:

buildPythonPackage (finalAttrs: {
  pname = "zopfli";
  version = "0.4.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-qO6ZKyVJ4JDNPwF4v2Bt1Bop4GE6BM31BUIkZixy3OY=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "setuptools<72.2.0" "setuptools"
  '';

  buildInputs = [ zopfli ];
  env.USE_SYSTEM_ZOPFLI = "True";
  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools-scm ];
  pyproject = true;

  meta = {
    description = "CPython bindings for zopfli";
    homepage = "https://github.com/obp/py-zopfli";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.sternenseemann ];
  };
})
