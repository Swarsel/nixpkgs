{
  lib,
  stdenv,
  fetchFromGitHub,
  perl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sec";
  version = "2.9.4";

  src = fetchFromGitHub {
    owner = "simple-evcorr";
    repo = "sec";
    rev = finalAttrs.version;
    sha256 = "sha256-XF4Wc1uRz1PrIwDGh9AUsR4s5nij1G+DgZUY8ey2ZJA=";
  };

  buildInputs = [ perl ];
  doCheck = false;

  installPhase = ''
    mkdir -p $out/bin $out/share/man/man1
    cp sec $out/bin
    cp sec.man $out/share/man/man1/sec.1
  '';

  dontBuild = false;

  meta = {
    description = "Simple Event Correlator";
    homepage = "https://simple-evcorr.github.io";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.tv ];
    platforms = lib.platforms.all;
    mainProgram = "sec";
  };
})
