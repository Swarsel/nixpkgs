{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  sqlite,
  wxwidgets_3_2,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "wxsqlite3";
  version = "4.11.2";

  src = fetchFromGitHub {
    owner = "utelle";
    repo = "wxsqlite3";
    rev = "v${finalAttrs.version}";
    hash = "sha256-RSAA4wZRouGPpIekfSXA8cTUb9ByCK2GbV5/mcJ/6eQ=";
  };

  nativeBuildInputs = [
    autoreconfHook
  ];

  buildInputs = [
    sqlite
    wxwidgets_3_2
  ];

  doCheck = true;

  checkPhase = ''
    runHook preCheck

    ./samples/minimal -t -s ./samples

    runHook postCheck
  '';

  enableParallelBuilding = true;

  meta = {
    description = "C++ wrapper around the public domain SQLite 3.x for wxWidgets";
    homepage = "https://utelle.github.io/wxsqlite3/";

    license = with lib.licenses; [
      lgpl3Plus
      gpl3Plus
    ];

    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
})
