{
  lib,
  fetchFromGitHub,
  bcrypt,
  buildPythonPackage,
  cryptography,
  jinja2,
  librouteros,
  mako,
  packaging,
  pytestCheckHook,
  pyyaml,
  requests,
  setuptools,
  tomlkit,
  versionCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "bundlewrap";
  version = "5.0.3";

  src = fetchFromGitHub {
    owner = "bundlewrap";
    repo = "bundlewrap";
    tag = finalAttrs.version;
    hash = "sha256-gncxzeAlfob0dXZ1iqMwqG5h+OyGxvPhrS0MZ+x0mbo=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    versionCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    bcrypt
    cryptography
    jinja2
    mako
    packaging
    pyyaml
    requests
    tomlkit
    librouteros
  ];

  enabledTestPaths = [
    # only unit tests as integration tests need a OpenSSH client/server setup
    "tests/unit"
  ];

  pyproject = true;
  pythonImportsCheck = [ "bundlewrap" ];
  versionCheckProgram = "${placeholder "out"}/bin/bw";

  meta = {
    description = "Easy, Concise and Decentralized Config management with Python";
    homepage = "https://bundlewrap.org/";
    changelog = "https://github.com/bundlewrap/bundlewrap/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = [ lib.licenses.gpl3 ];
    maintainers = with lib.maintainers; [ wamserma ];
    mainProgram = "bw";
  };
})
