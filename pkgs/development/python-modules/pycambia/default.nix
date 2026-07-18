{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  openssl,
  pkg-config,
  pytestCheckHook,
  rustPlatform,
}:
buildPythonPackage (finalAttrs: {
  pname = "pycambia";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "KyokoMiki";
    repo = "pycambia";
    tag = "v${finalAttrs.version}";
    hash = "sha256-5UHWAIR+qo16UUsi9D0e6W8UmQ4HUujNWLfJpyIrCUI=";
  };

  nativeBuildInputs = [
    pkg-config
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
  ];

  buildInputs = [ openssl ];
  nativeCheckInputs = [ pytestCheckHook ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) src;
    hash = "sha256-w7n/W7PDC3+DPCb//X462mowhEPw0k3HA1raAeu4t/c=";
  };

  pyproject = true;
  pythonImportsCheck = [ "cambia" ];

  meta = {
    description = "Python wrapper for compact disc ripper log checking utility cambia";
    homepage = "https://github.com/KyokoMiki/pycambia";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ undefined-landmark ];
  };
})
