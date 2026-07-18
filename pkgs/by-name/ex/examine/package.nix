{
  lib,
  stdenv,
  fetchFromGitHub,
  just,
  libcosmicAppHook,
  nix-update-script,
  pciutils,
  rustPlatform,
  usbutils,
  util-linux,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "examine";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "cosmic-utils";
    repo = "examine";
    tag = finalAttrs.version;
    hash = "sha256-6U8reOzeqamX/MG/mWbso+kjuZQ6cK8j9XhuEtGZ1q4=";
  };

  nativeBuildInputs = [
    just
    libcosmicAppHook
  ];

  cargoHash = "sha256-V+ClzaG7LnkOl84j5mVGJPTLVfaVqxaSH7ufmjXdwyM=";
  env.VERGEN_GIT_SHA = finalAttrs.version;

  preFixup = ''
    libcosmicAppWrapperArgs+=(--prefix PATH : ${
      lib.makeBinPath [
        pciutils
        usbutils
        util-linux
      ]
    })
  '';

  dontUseJustBuild = true;
  dontUseJustCheck = true;

  justFlags = [
    "--set"
    "prefix"
    (placeholder "out")
    "--set"
    "bin-src"
    "target/${stdenv.hostPlatform.rust.cargoShortTarget}/release/examine"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "System information viewer for the COSMIC Desktop";
    homepage = "https://github.com/cosmic-utils/examine";
    changelog = "https://github.com/cosmic-utils/examine/releases/tag/${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
    maintainers = with lib.maintainers; [ HeitorAugustoLN ];
    platforms = lib.platforms.linux;
    mainProgram = "examine";
  };
})
