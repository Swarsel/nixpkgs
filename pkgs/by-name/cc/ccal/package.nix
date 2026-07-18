{
  lib,
  stdenv,
  fetchurl,
  ghostscript_headless, # for ps2pdf binary
  makeWrapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ccal";
  version = "2.5.3";

  src = fetchurl {
    url = "https://ccal.chinesebay.com/ccal-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-PUy9yfkFzgKrSEBB+79/C3oxmuajUMbBbWNuGlpQ35Y=";
  };

  nativeBuildInputs = [ makeWrapper ];

  makeFlags = [
    "CXX:=$(CXX)"
    "BINDIR=$(out)/bin"
    "MANDIR=$(out)/share/man"
  ];

  # ccalpdf depends on a `ps2pdf` binary in PATH
  postFixup = ''
    wrapProgram $out/bin/ccalpdf \
      --prefix PATH : ${lib.makeBinPath [ ghostscript_headless ]}:$out/bin
  '';

  installTargets = [
    "install"
    "install-man"
  ];

  meta = {
    description = "Command line Chinese calendar viewer, similar to cal";
    homepage = "https://ccal.chinesebay.com/ccal.htm";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ sharzy ];
    platforms = lib.platforms.all;
  };
})
