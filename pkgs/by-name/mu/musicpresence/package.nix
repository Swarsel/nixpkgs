{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  e2fsprogs,
  fontconfig,
  freetype,
  libGL,
  libgpg-error,
  libx11,
  libxcb,
  makeWrapper,
  qt6,
  wayland,
  xkeyboard_config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "musicpresence";
  version = "2.3.6";

  src = fetchurl {
    url = "https://github.com/ungive/discord-music-presence/releases/download/v${finalAttrs.version}/musicpresence-${finalAttrs.version}-linux-x86_64.tar.gz";
    hash = "sha256-w3y1I6nnztEMaihbXIfQqB0ng6s07iA8bqC8PDq+E+I=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    libGL
    libxcb
    libx11
    wayland
    fontconfig
    freetype
    libgpg-error
    e2fsprogs
    stdenv.cc.cc.lib
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp -r usr/share $out/

    makeWrapper $out/share/musicpresence/bin/musicpresence $out/bin/musicpresence \
      --set XKB_CONFIG_ROOT "${xkeyboard_config}/share/X11/xkb" \
      --prefix QT_PLUGIN_PATH : "${qt6.qtwayland}/${qt6.qtbase.qtPluginPrefix}" \
      --unset QT_STYLE_OVERRIDE

    runHook postInstall
  '';

  __structuredAttrs = true;
  dontBuild = true;
  dontConfigure = true;

  meta = {
    description = "Discord music status that works with any media player";
    homepage = "https://github.com/ungive/discord-music-presence";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];

    maintainers = with lib.maintainers; [
      wiyba
      nonplay
    ];

    platforms = [ "x86_64-linux" ];
    mainProgram = "musicpresence";
  };
})
