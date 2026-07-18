{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  gdk-pixbuf,
  glib,
  gtk3,
  pkg-config,
  rgbds,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sameboy";
  version = "1.0.2";

  src = fetchFromGitHub {
    owner = "LIJI32";
    repo = "SameBoy";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Sk5/Wojl9rFkTuBFSGN/W8oq8OJNrV5W3E8PdsaMll8=";
  };

  patches = [
    ./xdg-install-patch.diff
  ];

  postPatch = ''
    substituteInPlace OpenDialog/gtk.c \
      --replace-fail '"libgtk-3.so"' '"${gtk3}/lib/libgtk-3.so"'
  '';

  # glib and wrapGAppsHook3 are needed to make the Open ROM menu work.
  nativeBuildInputs = [
    pkg-config
    gdk-pixbuf
    rgbds
    glib
    wrapGAppsHook3
  ];

  buildInputs = [ SDL2 ];

  makeFlags = [
    "CONF=release"
    "FREEDESKTOP=true"
    "PREFIX=$(out)"
  ];

  postInstall = ''
    substituteInPlace $out/share/thumbnailers/sameboy.thumbnailer \
      --replace-fail "TryExec=sameboy-thumbnailer" "TryExec=$out/bin/sameboy-thumbnailer" \
      --replace-fail "Exec=sameboy-thumbnailer" "Exec=$out/bin/sameboy-thumbnailer"
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Game Boy, Game Boy Color, and Super Game Boy emulator";

    longDescription = ''
      SameBoy is a user friendly Game Boy, Game Boy Color and Super
      Game Boy emulator for macOS, Windows and Unix-like platforms.
      SameBoy is extremely accurate and includes a wide range of
      powerful debugging features, making it ideal for both casual
      players and developers. In addition to accuracy and developer
      capabilities, SameBoy has all the features one would expect from
      an emulator – from save states to scaling filters.
    '';

    homepage = "https://sameboy.github.io";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ NieDzejkob ];
    platforms = lib.platforms.linux;
    mainProgram = "sameboy";
  };
})
