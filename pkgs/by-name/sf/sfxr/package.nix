{
  lib,
  stdenv,
  fetchurl,
  SDL,
  desktop-file-utils,
  fetchpatch,
  gsettings-desktop-schemas,
  gtk3,
  pkg-config,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sfxr";
  version = "1.2.1";

  src = fetchurl {
    url = "https://www.drpetter.se/files/sfxr-sdl-${finalAttrs.version}.tar.gz";
    sha256 = "0dfqgid6wzzyyhc0ha94prxax59wx79hqr25r6if6by9cj4vx4ya";
  };

  patches = [
    # Fix segfault
    (fetchpatch {
      hash = "sha256-etn4AutkNrhEDH9Ep8MhH9JSJEd7V/JXwjQua5uhAmg=";
      url = "https://src.fedoraproject.org/rpms/sfxr/raw/223e58e68857c2018ced635e8209bb44f3616bf8/f/sfxr-sdl-gcc8x.patch";
    })
  ];

  postPatch = ''
    substituteInPlace Makefile --replace "usr/" ""
    substituteInPlace sdlkit.h --replace \
      "/usr/share/sfxr/sfxr.bmp" \
      "$out/share/sfxr/sfxr.bmp"
    substituteInPlace main.cpp \
      --replace \
      "/usr/share/sfxr/font.tga" \
      "$out/share/sfxr/font.tga" \
      --replace \
      "/usr/share/sfxr/ld48.tga" \
      "$out/share/sfxr/ld48.tga"
  '';

  nativeBuildInputs = [
    pkg-config
    desktop-file-utils
  ];

  buildInputs = [
    SDL
    gtk3
    gsettings-desktop-schemas
    wrapGAppsHook3
  ];

  makeFlags = [ "DESTDIR=$(out)" ];

  meta = {
    description = "Videogame sound effect generator";
    homepage = "http://www.drpetter.se/project_sfxr.html";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fgaz ];
    platforms = lib.platforms.unix;
    mainProgram = "sfxr";
    broken = stdenv.hostPlatform.isDarwin;
  };
})
