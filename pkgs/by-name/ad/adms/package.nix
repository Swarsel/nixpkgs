{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  bison,
  fetchpatch2,
  flex,
  gd,
  gperf,
  libxml2,
  perl,
  perlPackages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "adms";
  version = "2.3.7";

  src = fetchFromGitHub {
    owner = "Qucs";
    repo = "adms";
    rev = "release-${finalAttrs.version}";
    sha256 = "0i37c9k6q1iglmzp9736rrgsnx7sw8xn3djqbbjw29zsyl3pf62c";
  };

  patches = [
    # fix build with c23
    #   admsXml.c:645:8: error: too many arguments to function 'verilogaparse'; expected 0, have 1
    (fetchpatch2 {
      hash = "sha256-rSNBqdpuXA9ViyygRGn4KVknLCu0Q+UoOGLfoNAgccc=";
      url = "https://salsa.debian.org/science-team/adms/-/raw/01ef4a94a48736c49c67d90da506b34f6114f0b0/debian/patches/0002-fix-ftbfs-gcc-15.patch";
    })
  ];

  nativeBuildInputs = [ autoreconfHook ];

  buildInputs = [
    flex
    bison
    gperf
    libxml2
    perl
    gd
    perlPackages.XMLLibXML
  ];

  configureFlags = [ "--enable-maintainer-mode" ];

  meta = {
    description = "Automatic device model synthesizer";
    homepage = "https://github.com/Qucs/adms";
    license = lib.licenses.gpl3;
    platforms = with lib.platforms; unix;
  };
})
