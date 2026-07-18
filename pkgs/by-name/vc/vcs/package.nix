{
  lib,
  stdenv,
  fetchurl,
  coreutils,
  dejavu_fonts,
  ffmpeg,
  gawk,
  getopt,
  gnugrep,
  gnused,
  imagemagick,
  makeWrapper,
  mplayer,
  util-linux,
}:
let
  version = "1.13.4";
  gopt = if stdenv.hostPlatform.isLinux then util-linux else getopt;
  runtimeDeps = [
    coreutils
    ffmpeg
    gawk
    gnugrep
    gnused
    imagemagick
    mplayer
    gopt
  ];
in
stdenv.mkDerivation {
  inherit version;
  inherit dejavu_fonts;
  pname = "vcs";

  src = fetchurl {
    url = "http://p.outlyer.net/files/vcs/vcs-${version}.bash";
    sha256 = "0nhwcpffp3skz24kdfg4445i6j37ks6a0qsbpfd3dbi4vnpa60a0";
  };

  patches = [ ./fonts.patch ];
  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin
    mv vcs $out/bin/vcs
    substituteAllInPlace $out/bin/vcs
    chmod +x $out/bin/vcs
    wrapProgram $out/bin/vcs --argv0 vcs --set PATH "${lib.makeBinPath runtimeDeps}"
  '';

  unpackCmd = "mkdir src; cp $curSrc src/vcs";

  meta = {
    description = "Generates contact sheets from video files";
    homepage = "http://p.outlyer.net/vcs";
    license = lib.licenses.lgpl21Plus;
    maintainers = [ ];
    platforms = with lib.platforms; unix;
    mainProgram = "vcs";
  };
}
