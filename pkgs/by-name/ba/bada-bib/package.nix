{
  lib,
  fetchFromGitHub,
  appstream-glib,
  desktop-file-utils,
  gdk-pixbuf,
  gettext,
  glib,
  gobject-introspection,
  gtk4,
  gtksourceview5,
  libadwaita,
  libxml2,
  meson,
  ninja,
  pkg-config,
  python3Packages,
  wrapGAppsHook4,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "bada-bib";
  version = "0.8.1";

  src = fetchFromGitHub {
    owner = "RogerCrocker";
    repo = "BadaBib";
    tag = "v${finalAttrs.version}";
    sha256 = "sha256-8lpkmQCVh94+qhFJijAIVyYeJRFz2u/OYR1C5E+gtOE=";
  };

  postPatch = ''
    patchShebangs build-aux/meson/postinstall.py
  '';

  nativeBuildInputs = [
    gettext
    gobject-introspection
    libxml2
    meson
    ninja
    pkg-config
    wrapGAppsHook4
  ];

  buildInputs = [
    gdk-pixbuf
    glib
    gtk4
    gtksourceview5
    libadwaita
  ];

  nativeCheckInputs = [
    appstream-glib
    desktop-file-utils
  ];

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  postFixup = ''
    wrapPythonProgramsIn "$out/libexec" "$out ''${pythonPath[*]}"
  '';

  dontWrapGApps = true; # Needs python wrapper
  pyproject = false;

  pythonPath = with python3Packages; [
    bibtexparser
    pygobject3
  ];

  meta = {
    description = "Simple BibTeX Viewer and Editor";
    homepage = "https://github.com/RogerCrocker/BadaBib";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.Cogitri ];
    mainProgram = "badabib";
  };
})
