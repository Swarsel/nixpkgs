{
  lib,
  stdenv,
  buildGoModule,
  fetchFromSourcehut,
  libGL,
  libx11,
  libxcb,
  libxcursor,
  libxfixes,
  libxkbcommon,
  pkg-config,
  sqlite,
  vulkan-headers,
  wayland,
}:

buildGoModule (finalAttrs: {
  pname = "transito";
  version = "0.10.0";

  src = fetchFromSourcehut {
    owner = "~mil";
    repo = "transito";
    rev = "v${finalAttrs.version}";
    hash = "sha256-87U9RdlP260ApkGJB3dLitxAdY3I9nWrukxzRnwuJ2E=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    vulkan-headers
    libxkbcommon
    wayland
    libx11
    libxcursor
    libxfixes
    libxcb
    libGL
    sqlite
  ];

  vendorHash = "sha256-mgvfrNKvdjLa7O0oTSec8u3eHHU66ZDqpKzNeeyy2J0=";
  doCheck = false; # no test

  postInstall = ''
    install -Dm644 -t $out/share/applications assets/transito.desktop
    for icon in assets/transito_*.png; do
      name=$(basename $icon .png)
      install -Dm644 $icon $out/share/icons/hicolor/''${name#transito_}/apps/transito.png
    done
  '';

  ldflags = [ "-X git.sr.ht/~mil/transito/src/uipages/pageconfig.Commit=${finalAttrs.version}" ];
  tags = [ "sqlite_math_functions" ];

  meta = {
    description = "Data-provider-agnostic (GTFS) public transportation app";

    longDescription = ''
      Transito is a data-provider-agnostic public transportation app
      that let's you route between locations using openly available
      public GTFS feeds.  Utilizing the Mobroute library,
      the Transito app lets you performs routing calculations offline
      (no network calls once data is initially fetched).

      Overall, Transito aims to be an opensource alternative
      to proprietary routing apps to get users from point A to point B
      via public transit without comprising privacy or user freedoms.
      It works in many well-connected metros which have publicly available
      GTFS data, to name a few: Lisbon, NYC, Brussels, Krakow, and Bourges.
    '';

    homepage = "https://git.sr.ht/~mil/transito";
    changelog = "https://git.sr.ht/~mil/transito/refs/v${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.McSinyx ];
    platforms = lib.platforms.unix;
    mainProgram = "transito";
    broken = stdenv.hostPlatform.isDarwin;
  };
})
