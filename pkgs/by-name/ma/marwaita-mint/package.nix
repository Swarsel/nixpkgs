{
  lib,
  fetchFromGitHub,
  gdk-pixbuf,
  gitUpdater,
  gtk-engine-murrine,
  gtk_engines,
  librsvg,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "marwaita-mint";
  version = "24";

  src = fetchFromGitHub {
    owner = "darkomarko42";
    repo = "marwaita-mint";
    rev = finalAttrs.version;
    hash = "sha256-Bvo4IRE1yXu4SDvyDY8mrMyZivqYEVQwkdSH+UZruSI=";
  };

  buildInputs = [
    gdk-pixbuf
    gtk_engines
    librsvg
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/themes
    cp -a Marwaita* $out/share/themes
    runHook postInstall
  '';

  propagatedUserEnvPkgs = [
    gtk-engine-murrine
  ];

  passthru.updateScript = gitUpdater { };

  meta = {
    description = "Variation for marwaita GTK theme based on linux mint color scheme";
    homepage = "https://www.pling.com/p/1674243";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ romildo ];
    platforms = lib.platforms.unix;
  };
})
