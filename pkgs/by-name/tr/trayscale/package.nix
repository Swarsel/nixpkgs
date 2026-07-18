{
  lib,
  fetchFromGitHub,
  buildGoModule,
  gobject-introspection,
  gtk4,
  libadwaita,
  pkg-config,
  tailscale,
  wrapGAppsHook4,
}:

buildGoModule (finalAttrs: {
  pname = "trayscale";
  version = "0.18.9";

  src = fetchFromGitHub {
    owner = "DeedleFake";
    repo = "trayscale";
    tag = "v${finalAttrs.version}";
    hash = "sha256-MPKOxU3b+i85Y5xaCYWzy7fLWi3K9rN7yPtaUv7fsEU=";
  };

  nativeBuildInputs = [
    pkg-config
    gobject-introspection
    wrapGAppsHook4
  ];

  buildInputs = [
    gtk4
    libadwaita
  ];

  vendorHash = "sha256-G53kmNrTXhHCT5Axb/h9Mkbz/S2mScxnYjn07fBT2Lc=";
  # there are no actual tests, and it takes 20 minutes to rebuild
  doCheck = false;

  postInstall = ''
    sh ./dist.sh install $out
    glib-compile-schemas $out/share/glib-2.0/schemas
  '';

  preFixup = ''
    gappsWrapperArgs+=(--prefix PATH : "${tailscale}/bin")
  '';

  ldflags = [
    "-s"
    "-w"
    "-X=deedles.dev/trayscale/internal/metadata.version=${finalAttrs.version}"
  ];

  subPackages = [ "cmd/trayscale" ];

  meta = {
    description = "Unofficial GUI wrapper around the Tailscale CLI client";
    homepage = "https://github.com/DeedleFake/trayscale";
    changelog = "https://github.com/DeedleFake/trayscale/releases/tag/${finalAttrs.src.rev}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sikmir ];
    platforms = lib.platforms.unix;
    mainProgram = "trayscale";
  };
})
