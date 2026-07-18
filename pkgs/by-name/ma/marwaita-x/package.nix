{
  lib,
  fetchFromGitHub,
  gdk-pixbuf,
  gtk-engine-murrine,
  gtk_engines,
  librsvg,
  nix-update-script,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "marwaita-x";
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "darkomarko42";
    repo = "marwaita-x";
    rev = finalAttrs.version;
    hash = "sha256-x5b3aaasYbxFGvdNNF6vIrF/ZZWBGbdS2kEuB1rwOlA=";
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

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "New version for Marwaita GTK theme";
    homepage = "https://www.pling.com/p/2044790/";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ romildo ];
    platforms = lib.platforms.unix;
  };
})
