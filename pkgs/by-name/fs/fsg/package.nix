{
  lib,
  stdenv,
  fetchurl,
  glib,
  gtk2,
  libGL,
  libGLU,
  libx11,
  pkg-config,
  runtimeShell,
  wxwidgets_3_2,
  xorgproto,
}:

stdenv.mkDerivation rec {
  pname = "fsg";
  version = "4.4";

  src = fetchurl {
    url = "https://raw.githubusercontent.com/ctrlcctrlv/wxsand/5716c16b655ca3670e7acd76372b43763bec20d1/fsg-src-${version}-ORIGINAL.tar.gz";
    sha256 = "1756y01rkvd3f1pkj88jqh83fqcfl2fy0c48mcq53pjzln9ycv8c";
    name = "fsg-src-${version}.tar.gz";
  };

  patches = [ ./wxgtk-3.2.patch ];

  # use correct wx-config for cross-compiling
  postPatch = ''
    substituteInPlace makefile \
      --replace-fail 'wx-config' "${lib.getExe' wxwidgets_3_2 "wx-config"}"
  '';

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    glib
    libGLU
    libGL
    wxwidgets_3_2
    libx11
    xorgproto
  ];

  makeFlags = [
    "CPP=${stdenv.cc.targetPrefix}c++"
  ];

  preBuild = ''
    sed -e '
      s@currentProbIndex != 100@0@;
    ' -i MainFrame.cpp
    sed -re '/ctrans_prob/s/energy\[center][+]energy\[other]/(int)(fmin(energy[center]+energy[other],99))/g' -i Canvas.cpp
  '';

  installPhase = ''
    mkdir -p $out/bin $out/libexec
    cp sand $out/libexec
    echo -e '#!${runtimeShell}\nLC_ALL=C '$out'/libexec/sand "$@"' >$out/bin/fsg
    chmod a+x $out/bin/fsg
  '';

  hardeningDisable = [ "format" ];

  meta = {
    description = "Cellular automata engine tuned towards the likes of Falling Sand";
    maintainers = [ lib.maintainers.raskin ];
    platforms = lib.platforms.linux;
    mainProgram = "fsg";
  };
}
