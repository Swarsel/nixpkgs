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

stdenvNoCC.mkDerivation rec {
  pname = "marwaita";
  version = "23";

  src = fetchFromGitHub {
    owner = "darkomarko42";
    repo = "marwaita";
    rev = version;
    hash = "sha256-NFXvaKASWltskCSOidXDNVZpFpdpCTnuWjpfETxiI8U=";
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
    description = "GTK theme supporting Budgie, Pantheon, Mate, Xfce4 and GNOME desktops";
    homepage = "https://www.pling.com/p/1239855/";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.romildo ];
    platforms = lib.platforms.unix;
  };
}
