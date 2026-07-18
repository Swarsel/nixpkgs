{
  lib,
  stdenv,
  fetchFromGitHub,
  callPackage,
  nix-update-script,
  pkg-config,
  rustPlatform,
  versionCheckHook,
  zstd,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "wild-unwrapped";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "wild-linker";
    repo = "wild";
    tag = finalAttrs.version;
    hash = "sha256-v4lPgZDPvRTAekkU9Vku9llgpOsaVtKt91VFUGrEeKw=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    zstd
  ];

  cargoHash = "sha256-ADJLtTRXcVWcbvgwXvCs0wxcGp2XP1LZJUJ4hpuzVHQ=";
  env.ZSTD_SYS_USE_PKG_CONFIG = true;
  doCheck = false; # Tests are ran in passthru tests
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;

  cargoBuildFlags = [
    "-p"
    "wild-linker"
  ];

  passthru = {
    tests = callPackage ./adapterTest.nix { wild-unwrapped = finalAttrs.finalPackage; };
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Very fast linker for Linux";
    homepage = "https://github.com/wild-linker/wild";
    changelog = "https://github.com/wild-linker/wild/blob/${finalAttrs.version}/CHANGELOG.md";

    license = [
      lib.licenses.asl20 # or
      lib.licenses.mit
    ];

    maintainers = with lib.maintainers; [ RossSmyth ];
    # Wild can run on Linux and Darwin, but can only target ELF platforms.
    # On linux this is native, on Darwin this is cross (or emulated)
    platforms = with lib.platforms; lib.optionals (stdenv.targetPlatform.isElf) (linux ++ darwin);
    mainProgram = "wild";
  };
})
