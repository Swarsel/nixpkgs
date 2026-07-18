{
  lib,
  stdenv,
  fetchurl,
  fetchzip,
  libx11,
  withBigAtlas ? true,
  withEphemeris ? true,
  withMoonsEphemeris ? true,
}:
stdenv.mkDerivation {
  pname = "astrolog";
  version = "7.70";

  src = fetchzip {
    url = "https://www.astrolog.org/ftp/ast77src.zip";
    hash = "sha256-rG7njEtnHwUDqWstj0bQxm2c9CbsOmWOCYs0FtiVoJE=";
    stripRoot = false;
  };

  buildInputs = [ libx11 ];
  env.NIX_CFLAGS_COMPILE = "-Wno-format-security";

  installPhase =
    let
      ephemeris = fetchzip {
        hash = "sha256-+on9LE27hCPRacHaIo6wz6M3V+G1QpyJ1Rp4wHbycM0=";
        stripRoot = false;
        url = "http://astrolog.org/ftp/ephem/astephem.zip";
      };
      moonsEphemeris = fetchzip {
        hash = "sha256-bHJc1yyR2loSOC4QJWsYNtKRYpxN9ZnKK5cWCapAptI=";
        stripRoot = false;
        url = "https://www.astrolog.org/ftp/ephem/moons/sepm.zip";
      };
      atlas = fetchurl {
        hash = "sha256-sEiuc7azeBA5959QOIo0qllXqHo7LABGV4sB08xNWsM=";
        url = "http://astrolog.org/ftp/atlas/atlasbig.as";
      };
    in
    ''
      mkdir -p $out/bin $out/astrolog
      cp *.as $out/astrolog
      install astrolog $out/bin
      ${lib.optionalString withBigAtlas "cp ${atlas} $out/astrolog/atlas.as"}
      ${lib.optionalString withEphemeris ''
        sed -i "/-Yi1/s#\".*\"#\"$out/ephemeris\"#" $out/astrolog/astrolog.as
        mkdir -p $out/ephemeris
        cp -r ${ephemeris}/*.se1 $out/ephemeris
      ''}
      ${lib.optionalString withMoonsEphemeris ''
        sed -i "/-Yi1/s#\".*\"#\"$out/ephemeris\"#" $out/astrolog/astrolog.as
        mkdir -p $out/ephemeris
        cp -r ${moonsEphemeris}/*.se1 $out/ephemeris
      ''}
    '';

  patchPhase = ''
    sed -i "s:~/astrolog:$out/astrolog:g" astrolog.h
    substituteInPlace Makefile --replace cc "$CC" --replace strip "$STRIP"
  '';

  meta = {
    description = "Freeware astrology program";
    homepage = "https://astrolog.org/astrolog.htm";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ kmein ];
    platforms = lib.platforms.linux;
    mainProgram = "astrolog";
  };
}
