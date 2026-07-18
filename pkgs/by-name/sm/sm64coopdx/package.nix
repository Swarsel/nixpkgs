{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  copyDesktopItems,
  curl,
  hexdump,
  imagemagick,
  libGL,
  makeDesktopItem,
  makeWrapper,
  python3,
  sm64baserom,
  writeTextFile,
  zlib,
  enableCoopNet ? true,
  enableDiscord ? true,
  enableTextureFix ? true,
}:
let
  libc_hack = writeTextFile {
    destination = "/include/libc.h";
    name = "libc-hack";

    # https://stackoverflow.com/questions/21768542/libc-h-no-such-file-or-directory-when-compiling-nanomsg-pipeline-sample
    text = ''
      #include <unistd.h>
      #include <string.h>
      #include <pthread.h>
    '';
  };
  baserom =
    (sm64baserom.override {
      region = "us";
      showRegionMessage = false;
    }).romPath;
in
# note: there is a generic builder in pkgs/games/sm64ex/generic.nix that is meant to help build sm64ex and its forks; however sm64coopdx has departed significantly enough in its build that it doesn't make sense to use that other than the baseRom derivation
stdenv.mkDerivation (finalAttrs: {
  pname = "sm64coopdx";
  version = "1.5.1";

  src = fetchFromGitHub {
    owner = "coop-deluxe";
    repo = "sm64coopdx";
    tag = "v${finalAttrs.version}";
    hash = "sha256-AadjXTjUBnSbHP8tRHKvWotW58s5tMUJGtxbdPxYg6E=";
  };

  patches = [ ./no-update-check.patch ];

  nativeBuildInputs = [
    makeWrapper
    copyDesktopItems
    imagemagick
  ];

  buildInputs = [
    curl
    hexdump
    libc_hack
    python3
    SDL2
    zlib
    libGL
  ];

  makeFlags = [
    "BREW_PREFIX=/not-exist"
    "DISCORD_SDK=${if enableDiscord then "1" else "0"}"
    "TEXTURE_FIX=${if enableTextureFix then "1" else "0"}"
    "COOPNET=${if enableCoopNet then "1" else "0"}"
  ];

  preBuild = ''
    # the baserom is needed both at build time and run time
    ln -s ${baserom} baserom.us.z64
    # remove -march flags, stdenv manages them
    substituteInPlace Makefile \
      --replace-fail ' -march=$(TARGET_ARCH)' ""
  '';

  installPhase = ''
    runHook preInstall

    local built=$PWD/build/us_pc
    local share=$out/share/sm64coopdx
    mkdir -p $share
    cp $built/sm64coopdx $share/sm64coopdx
    cp -r $built/{dynos,lang,mods,palettes} $share
    # the baserom is needed both at build time and run time
    ln -s ${baserom} $share/baserom.us.z64

    ${lib.optionalString enableDiscord ''
      cp $built/libdiscord_game_sdk* $share
    ''}

    magick ${finalAttrs.icon} icon.png
    for size in 16 24 32 48 64 128 256 512; do
      mkdir -p $out/share/icons/hicolor/"$size"x"$size"/apps
      magick icon-0.png -resize "$size"x"$size" $out/share/icons/hicolor/"$size"x"$size"/apps/${finalAttrs.pname}.png
    done

    # coopdx always tries to load resources from the binary's directory, with no obvious way to change. Thus this small wrapper script to always run from the /share directory that has all the resources
    mkdir -p $out/bin
    makeWrapper $share/sm64coopdx $out/bin/sm64coopdx \
      --chdir $share

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Game" ];
      desktopName = "sm64coopdx";
      exec = "sm64coopdx";
      icon = finalAttrs.pname;
      name = finalAttrs.pname;
    })
  ];

  enableParallelBuilding = true;
  icon = "${finalAttrs.src}/res/icon.ico";

  meta = {
    description = "Multiplayer fork of the Super Mario 64 decompilation";

    longDescription = ''
      This is a fork of sm64ex-coop, which was itself a fork of sm64ex, which was a fork of the sm64 decompilation project.

      It allows multiple people to play within and across levels, has multiple character models, and mods in the form of lua scripts.

      Arguments:

      - `enableTextureFix`: (default: `true`) whether to enable texture fixes. Upstream describes disabling this as "for purists"
      - `enableDiscord`: (default: `true`) whether to enable discord integration, which allows showing status and connecting to games over discord
      - `enableCoopNet`: (default: `true`) whether to enable Co-op Net integration, a server made specifically for multiplayer sm64
    '';

    homepage = "https://sm64coopdx.com/";
    changelog = "https://github.com/coop-deluxe/sm64coopdx/releases/tag/${finalAttrs.version}";
    license = lib.licenses.unfree;

    sourceProvenance = with lib.sourceTypes; [
      fromSource
      # The lua engine, discord sdk, and coopnet library are vendored pre-built. See https://github.com/coop-deluxe/sm64coopdx/tree/v1.0.3/lib
      binaryNativeCode
    ];

    maintainers = [ lib.maintainers.shelvacu ];
    platforms = lib.platforms.x86;
    mainProgram = "sm64coopdx";
  };
})
