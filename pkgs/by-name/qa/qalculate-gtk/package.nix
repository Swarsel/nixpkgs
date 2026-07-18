{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  curl,
  desktopToDarwinBundle,
  gtk-mac-integration-gtk3,
  gtk3,
  libqalculate,
  pkg-config,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "qalculate-gtk";
  version = "5.12.0";

  src = fetchFromGitHub {
    owner = "qalculate";
    repo = "qalculate-gtk";
    tag = "v${finalAttrs.version}";
    hash = "sha256-c0n0iu8KB0sK7dnvMcwQAFQvtOmaBpET4oRRufliN4k=";
  };

  nativeBuildInputs = [
    pkg-config
    autoreconfHook
    wrapGAppsHook3
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ desktopToDarwinBundle ];

  buildInputs = [
    libqalculate
    gtk3
    curl
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    gtk-mac-integration-gtk3
  ];

  enableParallelBuilding = true;
  hardeningDisable = [ "format" ];

  meta = {
    description = "Ultimate desktop calculator";
    homepage = "http://qalculate.github.io";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      doronbehar
      pentane
      aleksana
    ];

    platforms = lib.platforms.all;
    mainProgram = "qalculate-gtk";
  };
})
