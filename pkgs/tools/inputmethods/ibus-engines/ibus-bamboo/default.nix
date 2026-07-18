{
  lib,
  stdenv,
  fetchFromGitHub,
  go,
  libxtst,
  pkg-config,
  wrapGAppsHook3,
}:

stdenv.mkDerivation rec {
  pname = "ibus-bamboo";
  version = "0.8.4-rc6";

  src = fetchFromGitHub {
    owner = "BambooEngine";
    repo = pname;
    rev = "v" + lib.toUpper version;
    sha256 = "sha256-8eBrgUlzrfQkgzr0/Nz/0FQ98UBdV0GQcZhJVbmyOg0=";
  };

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook3
    go
  ];

  buildInputs = [
    libxtst
  ];

  makeFlags = [
    "PREFIX=${placeholder "out"}"
  ];

  preConfigure = ''
    export GOCACHE="$TMPDIR/go-cache"
    sed -i "s,/usr,$out," data/bamboo.xml
  '';

  meta = {
    description = "Vietnamese IME for IBus";
    homepage = "https://github.com/BambooEngine/ibus-bamboo";
    license = lib.licenses.gpl3;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    isIbusEngine = true;
  };
}
