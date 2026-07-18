{
  lib,
  stdenv,
  fetchurl,
  fontconfig,
  freetype,
  libx11,
  libxext,
  libxft,
  libxrender,
  libxscrnsaver,
  makeWrapper,
  patchelf,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gorilla-bin";
  version = "1.5.3.7";

  src = fetchurl {
    url = "https://gorilla.dp100.com/downloads/gorilla1537_64.bin";
    sha256 = "19ir6x4c01825hpx2wbbcxkk70ymwbw4j03v8b2xc13ayylwzx0r";
    name = "gorilla1537_64.bin";
  };

  nativeBuildInputs = [
    patchelf
    makeWrapper
  ];

  installPhase =
    let
      interpreter = "$(< \"$NIX_CC/nix-support/dynamic-linker\")";
      libPath = lib.makeLibraryPath [
        libxft
        libx11
        freetype
        fontconfig
        libxrender
        libxscrnsaver
        libxext
      ];
    in
    ''
      mkdir -p $out/opt/password-gorilla
      mkdir -p $out/bin
      cp gorilla-${finalAttrs.version} $out/opt/password-gorilla
      chmod ugo+x $out/opt/password-gorilla/gorilla-${finalAttrs.version}
      patchelf --set-interpreter "${interpreter}" "$out/opt/password-gorilla/gorilla-${finalAttrs.version}"
      makeWrapper "$out/opt/password-gorilla/gorilla-${finalAttrs.version}" "$out/bin/gorilla" \
        --prefix LD_LIBRARY_PATH : "${libPath}"
    '';

  unpackCmd = ''
    mkdir gorilla;
    cp $curSrc gorilla/gorilla-${finalAttrs.version};
  '';

  meta = {
    description = "Password Gorilla is a Tk based password manager";
    homepage = "https://github.com/zdia/gorilla/wiki";
    license = lib.licenses.gpl2Plus;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = [ lib.maintainers.namore ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "gorilla";
  };
})
