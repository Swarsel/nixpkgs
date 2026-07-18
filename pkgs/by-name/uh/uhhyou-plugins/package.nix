{
  lib,
  stdenv,
  fetchFromGitHub,
  cairo,
  cmake,
  fontconfig,
  freetype,
  gtkmm3,
  libx11,
  libxcb,
  libxcb-cursor,
  libxcb-keysyms,
  libxcb-util,
  libxcursor,
  libxinerama,
  libxkbcommon,
  libxrandr,
  pango,
  pkg-config,
  sqlite,
  writableTmpDirAsHomeHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "uhhyou-plugins";
  version = "0.70.0";

  src = fetchFromGitHub {
    owner = "ryukau";
    repo = "VSTPlugins";
    rev = "UhhyouPlugins${finalAttrs.version}";
    hash = "sha256-NkNP7kmOBLcXBA65PEwC0I/NIGzZm8wnAvDM74Cfsws=";
    fetchSubmodules = true;
  };

  postPatch = ''
    # see: https://github.com/ryukau/VSTPlugins/blob/master/build_instruction.md#linux-ubuntu
    patch -p1 -d lib/vst3sdk/vstgui4 < ci/linux_patch/cairographicscontext.patch
    patchShebangs lib/vst3sdk/vstgui4/vstgui/uidescription/editing/createuidescdata.sh
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    writableTmpDirAsHomeHook
  ];

  buildInputs = [
    cairo
    fontconfig
    freetype
    libxcb
    libxcb-util
    libxcb-cursor
    libxcb-keysyms
    libxkbcommon
    libx11
    libxrandr
    libxinerama
    libxcursor
    pango
    gtkmm3
    sqlite
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/vst3
    cp -r VST3/Release/*.vst3 $out/lib/vst3/

    runHook postInstall
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Collection of VST3 audio synthesis and processing plugins.";
    homepage = "https://ryukau.github.io/VSTPlugins/";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ magnetophon ];
    platforms = lib.platforms.linux;
  };
})
