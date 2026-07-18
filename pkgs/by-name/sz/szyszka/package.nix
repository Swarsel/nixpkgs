{
  lib,
  fetchFromGitHub,
  atk,
  cairo,
  gdk-pixbuf,
  glib,
  gtk4,
  pango,
  pkg-config,
  rustPlatform,
  wrapGAppsHook4,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "szyszka";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "qarmin";
    repo = "szyszka";
    rev = finalAttrs.version;
    hash = "sha256-LkXGKDFKaY+mg53ZEO4h2br/4eRle/QbSQJTVEMpAoY=";
  };

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    glib
    cairo
    pango
    atk
    gdk-pixbuf
    gtk4
  ];

  cargoHash = "sha256-0VlhBd1GpmynNflssizg+Y9D8Hr40rT7OzOSP4AmhxY=";

  postInstall = ''
    install -m 444 \
        -D data/com.github.qarmin.szyszka.desktop \
        -t $out/share/applications
    install -m 444 \
        -D data/com.github.qarmin.szyszka.metainfo.xml \
        -t $out/share/metainfo
    install -m 444 \
        -D data/icons/com.github.qarmin.szyszka.svg \
        -t $out/share/icons/hicolor/scalable/apps
  '';

  meta = {
    description = "Simple but powerful and fast bulk file renamer";
    homepage = "https://github.com/qarmin/szyszka";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "szyszka";
  };
})
