{
  lib,
  stdenv,
  fetchurl,
  brotli,
}:

stdenv.mkDerivation rec {
  pname = "angie-console-light";
  version = "1.8.2";

  src = fetchurl {
    url = "https://download.angie.software/files/${pname}/${pname}-${version}.tar.gz";
    hash = "sha256-q27UPgWvOoEXa8Ih3sEFuoO7u5gvLtpoe7ZJYMmZtRc=";
  };

  outputs = [
    "out"
    "doc"
  ];

  nativeBuildInputs = [ brotli ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/angie-console-light
    mv ./html $out/share/angie-console-light

    mkdir -p $doc/share/doc/angie-console-light
    mv ./LICENSE $doc/share/doc/angie-console-light

    # Create static gzip and brotli files
    find -L $out -type f -regextype posix-extended -iregex '.*\.(html|js|txt)' \
      -exec gzip --best --keep --force {} ';' \
      -exec brotli --best --keep --no-copy-stat {} ';'

    runHook postInstall
  '';

  dontBuild = true;
  dontConfigure = true;

  meta = {
    description = "Console Light is a lightweight, real-time activity monitoring interface";
    homepage = "https://angie.software/en/console/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ izorkin ];
    platforms = lib.platforms.all;
  };
}
