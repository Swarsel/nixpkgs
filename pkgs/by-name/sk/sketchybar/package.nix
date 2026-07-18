{
  lib,
  stdenv,
  fetchFromGitHub,
  apple-sdk_15,
  llvmPackages,
  nix-update-script,
  versionCheckHook,
}:

let
  inherit (stdenv.hostPlatform) system;

  target =
    {
      "aarch64-darwin" = "arm64";
    }
    .${system} or (throw "Unsupported system: ${system}");
in
stdenv.mkDerivation (finalAttrs: {
  pname = "sketchybar";
  version = "2.24.0";

  src = fetchFromGitHub {
    owner = "FelixKratz";
    repo = "SketchyBar";
    rev = "v${finalAttrs.version}";
    hash = "sha256-5tyc/yYzdV/3JTtujuj7le/14XkC7TlN/nZg7tOZsNg=";
  };

  nativeBuildInputs = [
    # TODO: Remove once #536365 reaches this branch
    llvmPackages.lld
  ];

  buildInputs = [
    apple-sdk_15
  ];

  makeFlags = [ target ];
  # TODO: Remove once #536365 reaches this branch
  env.NIX_CFLAGS_LINK = "-fuse-ld=lld";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp ./bin/sketchybar $out/bin/sketchybar

    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Highly customizable macOS status bar replacement";
    homepage = "https://github.com/FelixKratz/SketchyBar";
    changelog = "https://github.com/FelixKratz/SketchyBar/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3;

    maintainers = with lib.maintainers; [
      azuwis
      khaneliman
    ];

    platforms = lib.platforms.darwin;
    mainProgram = "sketchybar";
  };
})
