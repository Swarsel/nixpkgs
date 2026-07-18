{
  lib,
  fetchFromGitHub,
  gobject-introspection,
  gtk3,
  python3Packages,
  unstableGitUpdater,
  wrapGAppsHook3,
}:

python3Packages.buildPythonApplication {
  pname = "labwc-gtktheme";
  version = "0-unstable-2025-02-11";

  src = fetchFromGitHub {
    owner = "labwc";
    repo = "labwc-gtktheme";
    rev = "619fa316702a6c21a0d974d7cf3dde0b82f9f64b";
    hash = "sha256-mhpN8H42dJwc+3os3I48mmAWQJQCrO4yjbuMPTmHbsI=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    gobject-introspection
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk3
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp -a labwc-gtktheme.py $out/bin/labwc-gtktheme
    runHook postInstall
  '';

  pyproject = false;

  pythonPath = with python3Packages; [
    pygobject3
  ];

  passthru.updateScript = unstableGitUpdater { };

  meta = {
    description = "Create a labwc theme based on current Gtk theme";
    homepage = "https://github.com/labwc/labwc-gtktheme";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ romildo ];
    platforms = lib.platforms.unix;
    mainProgram = "labwc-gtktheme";
  };
}
