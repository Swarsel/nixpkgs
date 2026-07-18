{
  lib,
  stdenv,
  fetchurl,
  cairo,
  fontconfig,
  freetype,
  gdk-pixbuf,
  glib,
  gtk3,
  libGL,
  libpulseaudio,
  libx11,
  libxext,
  libxi,
  libxkbcommon,
  # For glewinfo
  libxmu,
  libxrender,
  makeWrapper,
  pixman,
  systemd,
  which,
  xdg-utils,
  zlib,
}:

let
  packages = [
    stdenv.cc.cc
    zlib
    glib
    libx11
    libxkbcommon
    libxmu
    libxi
    libxext
    libGL
    libxrender
    fontconfig
    freetype
    systemd
    libpulseaudio
    cairo
    gdk-pixbuf
    gtk3
    pixman
  ];
  libPath = lib.makeLibraryPath packages;
in
stdenv.mkDerivation rec {
  pname = "genymotion";
  version = "3.8.0";

  src = fetchurl {
    url = "https://dl.genymotion.com/releases/genymotion-${version}/genymotion-${version}-linux_x64.bin";
    sha256 = "sha256-Tgp9ud/Tq0K9ADf/POr+luuFm+QBWMucjKTbELbIveo=";
    name = "genymotion-${version}-linux_x64.bin";
  };

  nativeBuildInputs = [
    makeWrapper
    which
    xdg-utils
  ];

  installPhase = ''
    mkdir -p $out/bin $out/libexec
    mv genymotion $out/libexec/
    ln -s $out/libexec/genymotion/{genymotion,player} $out/bin
  '';

  fixupPhase = ''
    patchInterpreter() {
      patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
        "$out/libexec/genymotion/$1"
    }

    patchExecutable() {
      patchInterpreter "$1"
      wrapProgram "$out/libexec/genymotion/$1" \
        --set "LD_LIBRARY_PATH" "${libPath}" \
        --unset "QML2_IMPORT_PATH" \
        --unset "QT_PLUGIN_PATH"
    }

    patchTool() {
      patchInterpreter "tools/$1"
      wrapProgram "$out/libexec/genymotion/tools/$1" \
        --set "LD_LIBRARY_PATH" "${libPath}"
    }

    patchExecutable genymotion
    patchExecutable player
    patchInterpreter qemu/x86_64/bin/qemu-img
    patchInterpreter qemu/x86_64/bin/qemu-system-x86_64

    patchTool adb
    patchTool aapt
    patchTool glewinfo

    rm $out/libexec/genymotion/libxkbcommon*
  '';

  unpackPhase = ''
    mkdir -p phony-home $out/share/applications
    export HOME=$TMP/phony-home

    mkdir ${pname}
    echo "y" | sh $src -d ${pname}
    sourceRoot=${pname}

    substitute phony-home/.local/share/applications/genymobile-genymotion.desktop \
      $out/share/applications/genymobile-genymotion.desktop --replace "$TMP/${pname}" "$out/libexec"
  '';

  meta = {
    description = "Fast and easy Android emulation";

    longDescription = ''
      Genymotion is a relatively fast Android emulator which comes with
      pre-configured Android (x86 with OpenGL hardware acceleration) images,
      suitable for application testing.
    '';

    homepage = "https://www.genymotion.com/";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = [ lib.maintainers.puffnfresh ];
    platforms = [ "x86_64-linux" ];
  };
}
