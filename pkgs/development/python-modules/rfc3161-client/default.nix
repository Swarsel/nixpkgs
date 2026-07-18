{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cryptography,
  perl,
  pretend,
  pytestCheckHook,
  rustPlatform,
}:

buildPythonPackage (finalAttrs: {
  pname = "rfc3161-client";
  version = "1.0.6";

  src = fetchFromGitHub {
    owner = "trailofbits";
    repo = "rfc3161-client";
    tag = "v${finalAttrs.version}";
    hash = "sha256-8OjohrHqUgsKXRZ28Au6Un6Wlzh81XVSQosoQC2f+Fs=";
  };

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
    perl
  ];

  nativeCheckInputs = [
    pytestCheckHook
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) src pname;
    hash = "sha256-jQsogV+qR0jAkHz/Slg9oBO/f96osU8YcjuaX4ZJQTk=";
  };

  dependencies = [
    cryptography
    pretend
  ];

  pyproject = true;

  pythonRelaxDeps = [
    "cryptography"
  ];

  meta = {
    description = "Opinionated Python RFC3161 Client";
    homepage = "https://github.com/trailofbits/rfc3161-client";
    changelog = "https://github.com/trailofbits/rfc3161-client/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ bot-wxt1221 ];
    platforms = lib.platforms.all;
  };
})
