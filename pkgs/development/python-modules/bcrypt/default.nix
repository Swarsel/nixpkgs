{
  lib,
  fetchFromGitHub,
  # for passthru.tests
  asyncssh,
  buildPythonPackage,
  cargo,
  django,
  fastapi,
  paramiko,
  pytestCheckHook,
  rustPlatform,
  rustc,
  setuptools,
  setuptools-rust,
  twisted,
}:

buildPythonPackage rec {
  pname = "bcrypt";
  version = "5.0.0";

  src = fetchFromGitHub {
    owner = "pyca";
    repo = "bcrypt";
    tag = version;
    hash = "sha256-7Dp07xoq6h+fiP7d7/TRRoYszWsyQF1c4vuFUpZ7u6U=";
  };

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    cargo
    rustc
  ];

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
    setuptools-rust
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit
      pname
      version
      src
      cargoRoot
      ;

    hash = "sha256-hYMJlwxnXA0ZOJiyZ8rDp9govVcc1SGkDfqUVngnUPQ=";
  };

  cargoRoot = "src/_bcrypt";
  pyproject = true;
  pythonImportsCheck = [ "bcrypt" ];

  passthru.tests = {
    inherit
      asyncssh
      django
      fastapi
      paramiko
      twisted
      ;
  };

  meta = {
    description = "Modern password hashing for your software and your servers";
    homepage = "https://github.com/pyca/bcrypt/";
    changelog = "https://github.com/pyca/bcrypt/blob/${src.tag}/CHANGELOG.rst";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.dotlambda ];
  };
}
