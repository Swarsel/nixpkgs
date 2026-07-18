{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cryptography,
  glibcLocales,
  gssapi,
  krb5,
  pytest-mock,
  pytestCheckHook,
  ruamel-yaml,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "pyspnego";
  version = "0.12.1";

  src = fetchFromGitHub {
    owner = "jborean93";
    repo = "pyspnego";
    tag = "v${finalAttrs.version}";
    hash = "sha256-nO+WNpgPAunBSFbrCRb/W511z0nXUIK7XT/SisTk2+0=";
  };

  env.LC_ALL = "en_US.UTF-8";

  nativeCheckInputs = [
    glibcLocales
    pytest-mock
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  dependencies = [ cryptography ];

  optional-dependencies = {
    kerberos = [
      gssapi
      krb5
    ];

    yaml = [ ruamel-yaml ];
  };

  pyproject = true;
  pythonImportsCheck = [ "spnego" ];

  meta = {
    description = "Python SPNEGO authentication library";
    homepage = "https://github.com/jborean93/pyspnego";
    changelog = "https://github.com/jborean93/pyspnego/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "pyspnego-parse";
  };
})
