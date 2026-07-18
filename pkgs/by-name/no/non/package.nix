{
  lib,
  stdenv,
  fetchFromGitHub,
  cairo,
  ladspa-header,
  libjack2,
  libjpeg,
  liblo,
  libsigcxx,
  libsndfile,
  lrdf,
  ntk,
  pkg-config,
  python3,
  waf,
}:

let
  wafHook = (waf.override { extraTools = [ "gccdeps" ]; }).hook;
in
stdenv.mkDerivation {
  pname = "non";
  version = "unstable-2021-01-28";

  src = fetchFromGitHub {
    owner = "linuxaudio";
    repo = "non";
    rev = "cdad26211b301d2fad55a26812169ab905b85bbb";
    hash = "sha256-iMJNMDytNXpEkUhL0RILSd25ixkm8HL/edtOZta0Pf4=";
  };

  nativeBuildInputs = [
    pkg-config
    wafHook
  ];

  buildInputs = [
    python3
    cairo
    libjpeg
    ntk
    libjack2
    libsndfile
    ladspa-header
    liblo
    libsigcxx
    lrdf
  ];

  env.CXXFLAGS = "-std=c++14";

  # NOTE: non provides its own waf script that is incompatible with new
  # python versions. If the script is not present, wafHook will install
  # a compatible version from nixpkgs.
  prePatch = ''
    rm waf
  '';

  meta = {
    description = "Lightweight and lightning fast modular Digital Audio Workstation";
    homepage = "http://non.tuxfamily.org";
    license = lib.licenses.lgpl21;
    maintainers = [ lib.maintainers.nico202 ];
    platforms = lib.platforms.linux;
  };
}
