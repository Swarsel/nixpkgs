{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  glib,
  libwnck,
  makeWrapper,
  pkg-config,
  procps,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xsuspender";
  version = "1.3";

  src = fetchFromGitHub {
    owner = "kernc";
    repo = "xsuspender";
    rev = finalAttrs.version;
    sha256 = "1c6ab1s9bbkjbmcfv2mny273r66dlz7sgxsmzfwi0fm2vcb2lwim";
  };

  outputs = [
    "out"
    "man"
    "doc"
  ];

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "cmake_minimum_required (VERSION 2.8 FATAL_ERROR)" "cmake_minimum_required(VERSION 3.10)"
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    makeWrapper
  ];

  buildInputs = [
    glib
    libwnck
  ];

  postInstall = ''
    wrapProgram $out/bin/xsuspender \
      --prefix PATH : "${lib.makeBinPath [ procps ]}"
  '';

  meta = {
    description = "Auto-suspend inactive X11 applications";
    homepage = "https://kernc.github.io/xsuspender/";
    license = lib.licenses.wtfpl;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "xsuspender";
  };
})
