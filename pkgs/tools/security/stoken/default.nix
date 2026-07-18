{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  gtk3,
  libxml2,
  nettle,
  pkg-config,
  withGTK3 ? !stdenv.hostPlatform.isStatic,
}:

stdenv.mkDerivation rec {
  pname = "stoken";
  version = "0.93";

  src = fetchFromGitHub {
    owner = "cernekee";
    repo = "stoken";
    rev = "v${version}";
    hash = "sha256-8N7TXdBu37eXWIKCBdaXVW0pvN094oRWrdlcy9raddI=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    libxml2
    nettle
  ]
  ++ lib.optionals withGTK3 [
    gtk3
  ];

  meta = {
    description = "Software Token for Linux/UNIX";
    homepage = "https://github.com/cernekee/stoken";
    license = lib.licenses.lgpl21Plus;
    maintainers = [ ];
    platforms = lib.platforms.all;
  };
}
