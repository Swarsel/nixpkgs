{
  lib,
  fetchFromGitHub,
  atk,
  buildGoModule,
  gdk-pixbuf,
  gobject-introspection,
  gtk-layer-shell,
  gtk3,
  pango,
  pkg-config,
  wrapGAppsHook3,
}:

buildGoModule (finalAttrs: {
  pname = "nwg-menu";
  version = "0.1.9";

  src = fetchFromGitHub {
    owner = "nwg-piotr";
    repo = "nwg-menu";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-3fN89HPwobMiijlvGJ80HexCBdsPLsEvAz9VH8dO4qc=";
  };

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook3
    gobject-introspection
  ];

  buildInputs = [
    atk
    gtk3
    gdk-pixbuf
    gtk-layer-shell
    pango
  ];

  vendorHash = "sha256-5gazNUZdPZh21lcnVFKPSDc/JLi8d6tqfP4NKMzPa8U=";
  doCheck = false;

  postInstall = ''
    mkdir -p $out/share/
    cp menu-start.css $out/share/
  '';

  preFixup = ''
    gappsWrapperArgs+=(--prefix XDG_DATA_DIRS : "$out/share")
  '';

  prePatch = ''
    for file in main.go tools.go; do
      substituteInPlace $file --replace '/usr/share/nwg-menu' $out/share
    done
  '';

  meta = {
    description = "MenuStart plugin for nwg-panel";
    homepage = "https://github.com/nwg-piotr/nwg-menu";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ berbiche ];
    platforms = lib.platforms.linux;
    mainProgram = "nwg-menu";
  };
})
