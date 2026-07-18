{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  cython,
  # dependencies
  decorator,
  k5test,
  # native dependencies
  krb5-c, # C krb5 library, not PyPI krb5
  # tests
  parameterized,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "gssapi";
  version = "1.10.1";

  src = fetchFromGitHub {
    owner = "pythongssapi";
    repo = "python-gssapi";
    tag = "v${finalAttrs.version}";
    hash = "sha256-A1y3PD+zycKxlZT2vZ9b9p8SMr+aZA62CIAUpi4eOvo=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "Cython == 3.1.3" Cython
    substituteInPlace setup.py \
      --replace-fail 'get_output(f"{kc} gssapi --prefix")' '"${lib.getDev krb5-c}"'
  '';

  env = lib.optionalAttrs (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) {
    GSSAPI_SUPPORT_DETECT = "false";
  };

  # k5test is marked as broken on darwin
  doCheck = !stdenv.hostPlatform.isDarwin;

  nativeCheckInputs = [
    k5test
    parameterized
    pytestCheckHook
  ];

  preCheck = ''
    mv gssapi/tests $TMPDIR/
    pushd $TMPDIR
  '';

  postCheck = ''
    popd
  '';

  build-system = [
    cython
    krb5-c
    setuptools
  ];

  dependencies = [ decorator ];
  pyproject = true;
  pythonImportsCheck = [ "gssapi" ];

  meta = {
    description = "Python GSSAPI Wrapper";
    homepage = "https://github.com/pythongssapi/python-gssapi";
    changelog = "https://github.com/pythongssapi/python-gssapi/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
  };
})
