{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  SDL2_image,
  cairo,
  cmake,
  ffmpeg,
  nix-update-script,
  pango,
  pkg-config,
  versionCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "oshu";
  version = "2.0.3";

  src = fetchFromGitHub {
    owner = "fmang";
    repo = "oshu";
    tag = finalAttrs.version;
    hash = "sha256-bVMEhaSaLtlxkPnu3rtue6Ov5m+8ymteBRLnWVv0YEI=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    pkg-config
    versionCheckHook
  ];

  buildInputs = [
    SDL2
    SDL2_image
    ffmpeg
    cairo
    pango
  ];

  doCheck = true;
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;
  checkTarget = "check";

  cmakeFlag = [
    "-DCMAKE_BUILD_TYPE=Release"
    "-DOSHU_DEFAULT_SKIN=minimal"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Lightweight osu! client for Linux and low-end systems";
    homepage = "https://github.com/fmang/oshu";
    changelog = "https://github.com/fmang/oshu/releases/tag/${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    maintainers = with lib.maintainers; [ castorNova2 ];
    platforms = lib.platforms.linux;
    mainProgram = "oshu";
  };
})
