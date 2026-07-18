{
  lib,
  stdenv,
  fetchurl,
  alsa-lib,
  buildFHSEnv,
  cairo,
  dpkg,
  freetype,
  gdk-pixbuf,
  glib,
  gmp,
  gtk3,
  libGL,
  libGLU,
  libdrm,
  libjack2,
  libjpeg_original,
  libpulseaudio,
  libuuid,
  libva,
  libvdpau,
  makeWrapper,
  nvidia_cg_toolkit,
  openssl,
  pango,
  sndio,
  twolame,
  udev,
  zlib,
}:
let
  fullPath = lib.makeLibraryPath [
    stdenv.cc.cc
    gtk3
    gdk-pixbuf
    cairo
    libjpeg_original
    glib
    pango
    libGL
    libGLU
    nvidia_cg_toolkit
    zlib
    openssl
    libuuid
    alsa-lib
    libjack2
    udev
    freetype
    libva
    libvdpau
    twolame
    gmp
    libdrm
    libpulseaudio
    sndio
  ];

  lightworks = stdenv.mkDerivation rec {
    pname = "lightworks";
    version = "2025.2";

    src =
      if stdenv.hostPlatform.system == "x86_64-linux" then
        fetchurl {
          url = "https://cdn.lwks.com/releases/${version}/Lightworks-${version}-${rev}.deb";
          sha256 = "sha256-MQsXl10I85qHiOosBEpdrLPq3iIiFlzumQv2R2sXNn8=";
        }
      else
        throw "${pname}-${version} is not supported on ${stdenv.hostPlatform.system}";

    nativeBuildInputs = [
      dpkg
      makeWrapper
    ];

    installPhase = ''
      mkdir -p $out/bin
      substitute usr/bin/lightworks $out/bin/lightworks \
        --replace "/usr/lib/lightworks" "$out/lib/lightworks"
      chmod +x $out/bin/lightworks

      cp -r usr/lib $out

      # /usr/share/fonts is not normally searched
      # This adds it to lightworks' search path while keeping the default
      # using the FONTCONFIG_FILE env variable
      echo "<?xml version='1.0'?>
      <!DOCTYPE fontconfig SYSTEM 'urn:fontconfig:fonts.dtd'>
      <fontconfig>
          <dir>/usr/share/fonts/truetype</dir>
          <include>/etc/fonts/fonts.conf</include>
      </fontconfig>" > $out/lib/lightworks/fonts.conf

      patchelf \
        --interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
        $out/lib/lightworks/ntcardvt

      wrapProgram $out/lib/lightworks/ntcardvt \
        --prefix LD_LIBRARY_PATH : $out/lib/lightworks:${fullPath} \
        --set FONTCONFIG_FILE $out/lib/lightworks/fonts.conf

      cp -r usr/share $out/share
    '';

    dontPatchELF = true;
    rev = "56356";
  };

in
# Lightworks expects some files in /usr/share/lightworks
buildFHSEnv {
  inherit (lightworks) pname version;
  runScript = "lightworks";
  targetPkgs = pkgs: [ lightworks ];

  meta = {
    description = "Professional Non-Linear Video Editor";
    homepage = "https://www.lwks.com/";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];

    maintainers = with lib.maintainers; [
      antonxy
      vojta001
      kashw2
      tombert
    ];

    platforms = [ "x86_64-linux" ];
    mainProgram = "lightworks";
  };
}
