{
  stdenv,
  fetchFromGitHub,
  bison,
  buildPackages,
  flex,
  stdenvNoLibc,
  texinfo,
}:

stdenvNoLibc.mkDerivation {
  pname = "vc4-newlib";
  version = "0-unstable-2017-01-08";

  src = fetchFromGitHub {
    owner = "itszor";
    repo = "newlib-vc4";
    rev = "89abe4a5263d216e923fbbc80495743ff269a510";
    sha256 = "131r4v0nn68flnqibjcvhsrys3hs89bn0i4vwmrzgjd7v1rbgqav";
  };

  nativeBuildInputs = [
    texinfo
    flex
    bison
  ];

  # newlib expects CC to build for build platform, not host platform
  preConfigure = ''
    export CC=cc
  '';

  configurePlatforms = [ "target" ];
  depsBuildBuild = [ buildPackages.stdenv.cc ];
  dontStrip = true;
  dontUpdateAutotoolsGnuConfigScripts = true;
  enableParallelBuilding = true;

  passthru = {
    incdir = "/${stdenv.targetPlatform.config}/include";
    libdir = "/${stdenv.targetPlatform.config}/lib";
  };

  meta = {
    homepage = "https://github.com/itszor/newlib-vc4";
  };
}
