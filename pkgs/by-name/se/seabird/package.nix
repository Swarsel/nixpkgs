{
  lib,
  fetchFromGitHub,
  buildGoModule,
  copyDesktopItems,
  gobject-introspection,
  gtk4,
  gtksourceview5,
  libadwaita,
  libxml2,
  pkg-config,
  vte-gtk4,
  wrapGAppsHook4,
}:

buildGoModule (finalAttrs: {
  pname = "seabird";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "getseabird";
    repo = "seabird";
    rev = "v${finalAttrs.version}";
    hash = "sha256-z+XEOqr7JX376AyGr0zx3AV3P+YqFbyspXMoxidCWY0=";
  };

  postPatch = ''
    substituteInPlace main.go --replace-fail 'version = "dev"' 'version = "${finalAttrs.version}"'
  '';

  nativeBuildInputs = [
    copyDesktopItems
    gobject-introspection
    libxml2
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    gtk4
    gtksourceview5
    libadwaita
    vte-gtk4
  ];

  vendorHash = "sha256-hPvMSAHWtcJULE9t8TKx8r0OpI9V287UPVACeORqOHA=";

  preBuild = ''
    go generate internal/icon/icon.go
  '';

  postInstall = ''
    install -Dm644 internal/icon/seabird.svg $out/share/icons/hicolor/scalable/dev.skynomads.Seabird.svg
  '';

  desktopItems = [ "dev.skynomads.Seabird.desktop" ];
  enableParallelBuilding = true;

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "Native Kubernetes desktop client";
    homepage = "https://getseabird.github.io";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ nicolas-goudry ];
    mainProgram = "seabird";
  };
})
