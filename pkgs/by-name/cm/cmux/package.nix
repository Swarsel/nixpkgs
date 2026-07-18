{
  lib,
  fetchurl,
  _7zz,
  makeBinaryWrapper,
  nix-update-script,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "cmux";
  version = "0.64.10";

  src = fetchurl {
    url = "https://github.com/manaflow-ai/cmux/releases/download/v${finalAttrs.version}/cmux-macos.dmg";
    hash = "sha256-+MKcMChZTFiDF482mVIh6mzeyKghDMV9gLA+6BjamXw=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    _7zz
    makeBinaryWrapper
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    cp -R cmux.app $out/Applications/

    mkdir -p $out/bin
    makeBinaryWrapper \
      "$out/Applications/cmux.app/Contents/MacOS/cmux" \
      "$out/bin/cmux"

    runHook postInstall
  '';

  __structuredAttrs = true;
  # Preserve the notarized signature of the bundled binaries and resources.
  dontFixup = true;
  sourceRoot = ".";
  # -snld prevents "ERROR: Dangerous symbolic link path was ignored"
  # -xr'!*:com.apple.*' avoids extended attributes being extracted as files
  # from the APFS image, which would corrupt the .app bundle.
  unpackCmd = "7zz x -snld -xr'!*:com.apple.*' $curSrc";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Native macOS terminal built on Ghostty, designed for AI coding agents";

    longDescription = ''
      cmux is a macOS-native terminal application built on Ghostty that
      provides vertical tabs, notification rings, an in-app browser, and
      first-class support for AI coding agents such as Claude Code.
      It exposes scriptable CLI and socket APIs.
    '';

    homepage = "https://cmux.com";
    changelog = "https://github.com/manaflow-ai/cmux/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ imcvampire ];
    platforms = lib.platforms.darwin;
    mainProgram = "cmux";
  };
})
