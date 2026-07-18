{
  lib,
  fetchFromGitHub,
  buildGoModule,
  cairo,
  glib,
  gtk3,
  libx11,
  pkg-config,
  wrapGAppsHook3,
  xcur2png,
  zlib,
}:

buildGoModule (finalAttrs: {
  pname = "nwg-look";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "nwg-piotr";
    repo = "nwg-look";
    rev = "v${finalAttrs.version}";
    hash = "sha256-YAFZZIUd/nvDwa3dXBoBL+dmPOVgJKv/taOjLMP4owI=";
  };

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    glib
    cairo
    xcur2png
    libx11.dev
    zlib
    gtk3
  ];

  vendorHash = "sha256-9jyR7RLpqdDvwgqlrvToKQlClRbk9ELxapbgb/OUB4I=";
  env.CGO_ENABLED = 1;

  postInstall = ''
    mkdir -p $out/share/nwg-look/langs
    cp stuff/main.glade $out/share/nwg-look/
    cp langs/* $out/share/nwg-look/langs
    install -D -m 644 stuff/nwg-look.desktop -t $out/share/applications
    install -D -m 644 stuff/nwg-look.svg -t $out/share/icons/hicolor/scalable/apps
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix PATH : "${glib.bin}/bin"
      --prefix PATH : "${xcur2png}/bin"
      --prefix XDG_DATA_DIRS : "${gtk3}/share/gsettings-schemas/${gtk3.name}"
    )
  '';

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "GTK settings editor, designed to work properly in wlroots-based Wayland environment";
    homepage = "https://github.com/nwg-piotr/nwg-look";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ max-amb ];
    platforms = lib.platforms.linux;
    mainProgram = "nwg-look";
  };
})
