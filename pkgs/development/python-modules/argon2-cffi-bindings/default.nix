{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cffi,
  libargon2,
  pytestCheckHook,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "argon2-cffi-bindings";
  version = "25.1.0";

  src = fetchFromGitHub {
    owner = "hynek";
    repo = "argon2-cffi-bindings";
    tag = version;
    hash = "sha256-UDPxwqEpsmByAPM7lz3cxZz8jWwCEdghPlKXt8zQrfc=";
  };

  buildInputs = [ libargon2 ];
  env.ARGON2_CFFI_USE_SYSTEM = 1;
  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools-scm
    cffi
  ];

  dependencies = [ cffi ];
  pyproject = true;
  pythonImportsCheck = [ "_argon2_cffi_bindings" ];

  meta = {
    description = "Low-level CFFI bindings for Argon2";
    homepage = "https://github.com/hynek/argon2-cffi-bindings";
    changelog = "https://github.com/hynek/argon2-cffi-bindings/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
