{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cargo,
  hypothesis,
  pytestCheckHook,
  rustPlatform,
  rustc,
}:

buildPythonPackage (finalAttrs: {
  pname = "jh2";
  version = "5.0.13";

  src = fetchFromGitHub {
    owner = "jawah";
    repo = "h2";
    tag = "v${finalAttrs.version}";
    hash = "sha256-zlc0R+DeE9bd5daD7sUrGHXU3NR5tRiiFvBrccSKCTI=";
    fetchSubmodules = true;
  };

  nativeCheckInputs = [
    hypothesis
    pytestCheckHook
  ];

  build-system = [
    cargo
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
    rustc
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-BPTgGc/qH101ZBlqiqwBe5KXXpnpDGe5K6GLqG99GSI=";
  };

  pyproject = true;
  pythonImportsCheck = [ "jh2" ];

  meta = {
    description = "HTTP/2 State-Machine based protocol implementation";
    homepage = "https://github.com/jawah/h2";
    changelog = "https://github.com/jawah/h2/blob/${finalAttrs.src.rev}/CHANGELOG.rst";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      fab
      techknowlogick
    ];
  };
})
