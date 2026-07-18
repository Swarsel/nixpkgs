{
  lib,
  fetchFromGitHub,
  autoPatchelfHook,
  libGL,
  libxkbcommon,
  nix-update-script,
  rustPlatform,
  wayland,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "openspeedrun";
  version = "0.3.3";

  src = fetchFromGitHub {
    owner = "SrWither";
    repo = "OpenSpeedRun";
    tag = "v${finalAttrs.version}";
    hash = "sha256-EZPApXUVhsaOYa6CnpR8IWeEoHEl89KJGGoBOYFqBV0=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  cargoHash = "sha256-WzsLEfDZpjpUrbyPOr5QUkTMrlAJoC9Rej5BMOKF7OM=";

  autoPatchelfIgnoreMissingDeps = [
    "libgcc_s.so.1"
  ];

  runtimeDependencies = [
    wayland
    libxkbcommon
    libGL
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Modern and minimalistic open-source speedrun timer";
    homepage = "https://github.com/SrWither/OpenSpeedRun";
    changelog = "https://github.com/SrWither/OpenSpeedRun/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.pyrox0 ];
    mainProgram = "openspeedrun";
  };
})
