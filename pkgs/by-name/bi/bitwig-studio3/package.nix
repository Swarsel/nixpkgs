{
  lib,
  stdenv,
  fetchurl,
  alsa-lib,
  cairo,
  dpkg,
  ffmpeg,
  freetype,
  gdk-pixbuf,
  glib,
  gtk3,
  libglvnd,
  libjack2,
  libx11,
  libxcb,
  libxcb-util,
  libxcb-wm,
  libxcursor,
  libxkbcommon,
  libxtst,
  makeWrapper,
  pulseaudio,
  wrapGAppsHook3,
  xdg-utils,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "bitwig-studio";
  version = "3.3.11";

  src = fetchurl {
    url = "https://downloads.bitwig.com/stable/${finalAttrs.version}/bitwig-studio-${finalAttrs.version}.deb";
    hash = "sha256-cF8gVPjM0KUcKOW09uFccp4/lzbUmZcBkVOwr/A/8Yw=";
  };

  nativeBuildInputs = [
    dpkg
    makeWrapper
    wrapGAppsHook3
  ];

  buildInputs = [
    alsa-lib
    cairo
    freetype
    gdk-pixbuf
    glib
    gtk3
    libxcb
    libxcb-util
    libxcb-wm
    zlib
    libxtst
    libxkbcommon
    pulseaudio
    libjack2
    libx11
    libglvnd
    libxcursor
    (lib.getLib stdenv.cc.cc)
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp -r opt/bitwig-studio $out/libexec
    ln -s $out/libexec/bitwig-studio $out/bin/bitwig-studio
    cp -r usr/share $out/share

    runHook postInstall
  '';

  postFixup = ''
    # patchelf fails to set rpath on BitwigStudioEngine, so we use
    # the LD_LIBRARY_PATH way

    find $out -type f -executable \
      -not -name '*.so.*' \
      -not -name '*.so' \
      -not -name '*.jar' \
      -not -path '*/resources/*' | \
    while IFS= read -r f ; do
      patchelf --set-interpreter "${stdenv.cc.bintools.dynamicLinker}" $f
      wrapProgram $f \
        "''${gappsWrapperArgs[@]}" \
        --prefix LD_LIBRARY_PATH : "${finalAttrs.ldLibraryPath}" \
        --prefix PATH : "${lib.makeBinPath [ ffmpeg ]}" \
        --suffix PATH : "${lib.makeBinPath [ xdg-utils ]}"
    done
  '';

  dontBuild = true;
  dontWrapGApps = true; # we only want $gappsWrapperArgs here
  ldLibraryPath = lib.strings.makeLibraryPath finalAttrs.buildInputs;

  meta = {
    description = "Digital audio workstation";

    longDescription = ''
      Bitwig Studio is a multi-platform music-creation system for
      production, performance and DJing, with a focus on flexible
      editing tools and a super-fast workflow.
    '';

    homepage = "https://www.bitwig.com/";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];

    maintainers = with lib.maintainers; [
      bfortz
      michalrus
      mrVanDalo
    ];

    platforms = [ "x86_64-linux" ];
  };
})
