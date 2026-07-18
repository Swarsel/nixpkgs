{
  lib,
  stdenv,
  fetchFromGitHub,
  gdk-pixbuf,
  gitUpdater,
  gtk-engine-murrine,
  gtk_engines,
  librsvg,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "marwaita-orange";
  version = "24";

  src = fetchFromGitHub {
    owner = "darkomarko42";
    repo = "marwaita-orange";
    rev = finalAttrs.version;
    hash = "sha256-/F/nboht7YG9pXVv7/ZvZ4QkxfB+h201G1KZLRohM80=";
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

  dontBuild = true;

  propagatedUserEnvPkgs = [
    gtk-engine-murrine
  ];

  passthru.updateScript = gitUpdater { };

  meta = {
    description = "Ubuntu Style of Marwaita GTK theme";
    homepage = "https://www.pling.com/p/1352833/";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.romildo ];
    platforms = lib.platforms.unix;
  };
})
