{
  lib,
  stdenv,
  fetchFromGitHub,
  writeText,
  conf ? null,
}:

stdenv.mkDerivation rec {
  pname = "sfm";
  version = "0.4";

  src = fetchFromGitHub {
    owner = "afify";
    repo = "sfm";
    rev = "v${version}";
    hash = "sha256-VwPux6n+azpR4qDkzZJia95pJJOaFDBBoz6/VwlC0zw=";
  };

  postPatch = lib.optionalString (conf != null) "cp ${configFile} config.def.h";
  makeFlags = [ "CC:=$(CC)" ];
  configFile = lib.optionalString (conf != null) (writeText "config.def.h" conf);
  installFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "Simple file manager";
    homepage = "https://github.com/afify/sfm";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ sikmir ];
    platforms = lib.platforms.unix;
    mainProgram = "sfm";
  };
}
