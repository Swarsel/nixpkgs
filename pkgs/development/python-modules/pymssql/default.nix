{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  freetds,
  gevent,
  krb5-c,
  openssl,
  psutil,
  pytestCheckHook,
  setuptools-scm,
  sqlalchemy,
  tomli,
}:

buildPythonPackage (finalAttrs: {
  pname = "pymssql";
  version = "2.3.13";

  src = fetchFromGitHub {
    owner = "pymssql";
    repo = "pymssql";
    tag = "v${finalAttrs.version}";
    hash = "sha256-UOb1gULAg5mNPiOiqcGpZ0Ux3f2Kz204gQ3Xn8fJFfA=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail '"standard-distutils ; python_version>='"'"'3.12'"'"'"' ""
  '';

  buildInputs = [
    freetds
    krb5-c
    openssl
  ];

  nativeCheckInputs = [
    gevent
    psutil
    pytestCheckHook
    sqlalchemy
  ];

  build-system = [
    cython
    setuptools-scm
    tomli
  ];

  pyproject = true;
  pythonImportsCheck = [ "pymssql" ];

  meta = {
    description = "Simple database interface for Python that builds on top of FreeTDS to provide a Python DB-API (PEP-249) interface to Microsoft SQL Server";
    homepage = "https://github.com/pymssql/pymssql";
    changelog = "https://github.com/pymssql/pymssql/blob/${finalAttrs.src.tag}/ChangeLog.rst";
    license = lib.licenses.lgpl21Plus;
    maintainers = [ lib.maintainers.sith-lord-vader ];
  };
})
