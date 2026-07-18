{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  curl,
  gpsd,
  gtk3,
  intltool,
  nix-update-script,
  pkg-config,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gpredict";
  version = "2.5.1";

  src = fetchFromGitHub {
    owner = "csete";
    repo = "gpredict";
    tag = "v${finalAttrs.version}";
    hash = "sha256-lP+QakQ+uTgBY8NNEC7DwQifh3Zi0ZKbarxNGB4onq0=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
    intltool
    wrapGAppsHook3
    autoreconfHook
  ];

  buildInputs = [
    curl
    gtk3
    gpsd
  ];

  __structuredAttrs = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Real time satellite tracking and orbit prediction";

    longDescription = ''
      Gpredict is a real time satellite tracking and orbit prediction program
      written using the GTK widgets. Gpredict is targetted mainly towards ham radio
      operators but others interested in satellite tracking may find it useful as
      well. Gpredict uses the SGP4/SDP4 algorithms, which are compatible with the
      NORAD Keplerian elements.
    '';

    homepage = "https://oz9aec.dk/gpredict/";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      cmcdragonkai
      pandapip1
    ];

    platforms = lib.platforms.linux;
    mainProgram = "gpredict";
  };
})
