{
  lib,
  stdenv,
  fetchurl,
  cddiscid,
  flac,
  glyr,
  id3v2,
  lame,
  libcdio-paranoia,
  makeWrapper,
  perlPackages,
  python3Packages,
  vorbis-tools,
  wget,
  which,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "abcde";
  version = "2.9.3";

  src = fetchurl {
    url = "https://abcde.einval.com/download/abcde-${finalAttrs.version}.tar.gz";
    hash = "sha256-BGzQu6eN1LvcvPgv5iWGXGDfNaAFSC3hOmaZxaO4MSQ=";
  };

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = with perlPackages; [
    perl
    MusicBrainz
    MusicBrainzDiscID
    IOSocketSSL
  ];

  postFixup = ''
    for cmd in abcde cddb-tool abcde-musicbrainz-tool; do
      wrapProgram "$out/bin/$cmd" \
        --prefix PERL5LIB : "$PERL5LIB" \
        --prefix PATH ":" ${
          lib.makeBinPath [
            "$out"
            which
            libcdio-paranoia
            cddiscid
            wget
            vorbis-tools
            id3v2
            python3Packages.eyed3
            lame
            flac
            glyr
          ]
        }
    done
  '';

  # FIXME: This package does not support `distmp3', `eject', etc.
  configurePhase = ''
    runHook preConfigure

    sed -i "s|^[[:blank:]]*prefix *=.*$|prefix = $out|g ;
            s|^[[:blank:]]*etcdir *=.*$|etcdir = $out/etc|g ;
            s|^[[:blank:]]*INSTALL *=.*$|INSTALL = install -c|g" \
      "Makefile";

    echo 'CDPARANOIA=${lib.getExe libcdio-paranoia}' >>abcde.conf
    echo CDROMREADERSYNTAX=cdparanoia >>abcde.conf

    substituteInPlace "abcde" \
      --replace-fail "/etc/abcde.conf" "$out/etc/abcde.conf"

    runHook postConfigure
  '';

  installFlags = [ "sysconfdir=$(out)/etc" ];

  meta = {
    description = "Command-line audio CD ripper";

    longDescription = ''
      abcde is a front-end command-line utility (actually, a shell
      script) that grabs tracks off a CD, encodes them to
      Ogg/Vorbis, MP3, FLAC, Ogg/Speex and/or MPP/MP+ (Musepack)
      format, and tags them, all in one go.
    '';

    homepage = "http://abcde.einval.com/wiki/";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
})
