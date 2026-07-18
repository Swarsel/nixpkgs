{
  lib,
  stdenv,
  fetchurl,
  cdparanoia,
  coreutils,
  eject,
  flac,
  gnugrep,
  makeWrapper,
  nano,
  perlPackages,
  sox,
  vorbis-tools,
  vorbisgain,
  which,
}:

stdenv.mkDerivation rec {
  pname = "crip";
  version = "3.9";

  src = fetchurl {
    url = "http://bach.dynet.com/crip/src/crip-${version}.tar.gz";
    sha256 = "0pk9152wll6fmkj1pki3fz3ijlf06jyk32v31yarwvdkwrk7s9xz";
  };

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [
    perlPackages.perl
    perlPackages.CDDB_get
  ];

  installPhase = ''
    mkdir -p $out/bin/

    for script in ${lib.escapeShellArgs scripts}; do
      cp $script $out/bin/

      substituteInPlace $out/bin/$script \
        --replace-fail '$editor = "vim";' '$editor = "${nano}/bin/nano";'

      wrapProgram $out/bin/$script \
        --set PERL5LIB "${perlPackages.makePerlPath [ perlPackages.CDDB_get ]}" \
        --set PATH "${toolDeps}"
    done
  '';

  scripts = [
    "crip"
    "editcomment"
    "editfilenames"
  ];

  toolDeps = lib.makeBinPath [
    cdparanoia
    coreutils
    eject
    flac
    gnugrep
    sox
    vorbis-tools
    vorbisgain
    which
  ];

  meta = {
    description = "Terminal-based ripper/encoder/tagger tool for creating Ogg Vorbis/FLAC files";
    homepage = "http://bach.dynet.com/crip/";
    license = lib.licenses.gpl1Only;
    maintainers = [ lib.maintainers.endgame ];
    platforms = lib.platforms.linux;
  };
}
