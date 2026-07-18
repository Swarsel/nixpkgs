{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  SDL2_gfx,
  SDL2_image,
  SDL2_mixer,
  SDL2_ttf,
  autoreconfHook,
  bzip2,
  curl,
  fluidsynth,
  freetype,
  gettext,
  gtk3,
  icu,
  libiconv,
  lua5_3,
  pkg-config,
  python3,
  qt5,
  readline,
  sqlite,
  wrapGAppsHook3,
  xz,
  zlib,
  enableSqlite ? true,
  gtkClient ? true,
  qtClient ? false,
  sdl2Client ? false,
  server ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "freeciv";
  version = "3.2.2";

  src = fetchFromGitHub {
    owner = "freeciv";
    repo = "freeciv";
    tag = "R${lib.replaceStrings [ "." ] [ "_" ] finalAttrs.version}";
    hash = "sha256-jZLCF0ap1MmLjZHwHsHQKQqHNTaAvUFJm0BdYAgkQyA=";
  };

  postPatch = ''
    for f in {common,utility}/*.py; do
      substituteInPlace $f \
        --replace-fail '/usr/bin/env python3' ${python3.interpreter}
    done
    for f in bootstrap/*.sh; do
      patchShebangs $f
    done
  '';

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ]
  ++ lib.optionals qtClient [ qt5.wrapQtAppsHook ]
  ++ lib.optionals gtkClient [ wrapGAppsHook3 ];

  buildInputs = [
    lua5_3
    zlib
    bzip2
    curl
    xz
    gettext
    libiconv
    icu
  ]
  ++ lib.optionals sdl2Client [
    SDL2
    SDL2_mixer
    SDL2_image
    SDL2_ttf
    SDL2_gfx
    freetype
    fluidsynth
  ]
  ++ lib.optionals gtkClient [ gtk3 ]
  ++ lib.optionals qtClient [ qt5.qtbase ]
  ++ lib.optional server readline
  ++ lib.optional enableSqlite sqlite;

  configureFlags = [
    "--enable-shared"
  ]
  ++ lib.optionals sdl2Client [
    "--enable-client=sdl2"
    "--enable-sdl-mixer=sdl2"
  ]
  ++ lib.optionals qtClient [
    "--enable-client=qt"
    "--with-qtver=qt5"
    "--with-qt5-includes=${qt5.qtbase.dev}/include"
  ]
  ++ lib.optionals gtkClient [ "--enable-client=gtk3.22" ]
  ++ lib.optional enableSqlite "--enable-fcdb=sqlite3"
  ++ lib.optional (!gtkClient) "--enable-fcmp=cli"
  ++ lib.optional (!server) "--disable-server";

  # configure is not smart enough to look for SDL2 headers under
  # .../SDL2, but thankfully $SDL2_PATH is almost exactly what we want
  preConfigure = ''
    export CPPFLAGS="$(echo $SDL2_PATH | sed 's#/nix/store/#-I/nix/store/#g')"
  '';

  postFixup =
    lib.optionalString qtClient ''
      wrapQtApp $out/bin/freeciv-qt
    ''
    + lib.optionalString gtkClient ''
      wrapGApp $out/bin/freeciv-gtk3.22
    '';

  dontWrapGApps = true;
  dontWrapQtApps = true;
  enableParallelBuilding = true;

  meta = {
    description = "Multiplayer (or single player), turn-based strategy game";

    longDescription = ''
      Freeciv is a Free and Open Source empire-building strategy game
      inspired by the history of human civilization. The game commences in
      prehistory and your mission is to lead your tribe from the stone age
      to the space age...
    '';

    homepage = "https://freeciv.org/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ pierron ];
    platforms = lib.platforms.unix;
    broken = qtClient && stdenv.hostPlatform.isDarwin; # Missing Qt5 development files
    hydraPlatforms = lib.platforms.linux; # sdl-config times out on darwin
  };
})
