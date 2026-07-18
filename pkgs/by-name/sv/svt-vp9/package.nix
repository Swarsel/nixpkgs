{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  nix-update-script,
  versionCheckHook,
  yasm,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "svt-vp9";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "OpenVisualCloud";
    repo = "SVT-VP9";
    tag = "v${finalAttrs.version}";
    hash = "sha256-M7XpHCqTxGgk/UOlMR0jEXist6vGie6abRYLnVvC6sg=";
  };

  outputs = [
    "bin"
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    cmake
    ninja
    yasm
  ];

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "VP9-compliant encoder targeting performance levels applicable to both VOD and live video applications";
    homepage = "https://github.com/OpenVisualCloud/SVT-VP9";
    changelog = "https://github.com/OpenVisualCloud/SVT-VP9/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.bsd2Patent;

    maintainers = with lib.maintainers; [
      niklaskorz
    ];

    platforms = [ "x86_64-linux" ];
    mainProgram = "SvtVp9EncApp";
  };
})
