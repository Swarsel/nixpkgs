{
  lib,
  fetchFromGitHub,
  dconf,
  fetchpatch,
  glibcLocales,
  gobject-introspection,
  gtk3,
  keybinder3,
  libnotify,
  libutempter,
  libwnck,
  nixosTests,
  python3,
  python3Packages,
  vte,
  wrapGAppsHook3,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "guake";
  version = "3.10.1";

  src = fetchFromGitHub {
    owner = "Guake";
    repo = "guake";
    tag = finalAttrs.version;
    hash = "sha256-TTDVJeM37SbpWucJGYoeYX9t4r1k3ldru9Cd02hBrU4=";
  };

  patches = [
    # Avoid trying to recompile schema at runtime,
    # the package should be responsible for ensuring it is up to date.
    # Without this, the package will try to run glib-compile-schemas
    # on every update, which is pointless and will crash
    # unless user has it installed.
    ./no-compile-schemas.patch

    # Avoid using pip since it fails on not being able to find setuptools.
    # Note: This is not a long-term solution, setup.py is deprecated.
    (fetchpatch {
      hash = "sha256-RjGRFJDTQX2meAaw3UZi/3OxAtIHbRZVpXTbcJk/scY=";
      revert = true;
      url = "https://github.com/Guake/guake/commit/14abaa0c69cfab64fe3467fbbea211d830042de8.patch";
    })

    # Revert switch to FHS.
    (fetchpatch {
      hash = "sha256-0asXI08XITkFc73EUenV9qxY/Eak+TzygRRK7GvhQUc=";
      revert = true;
      url = "https://github.com/Guake/guake/commit/8c7a23ba62ee262c033dfa5b0b18d3df71361ff4.patch";
    })
  ];

  nativeBuildInputs = [
    gobject-introspection
    wrapGAppsHook3
    python3Packages.pip
  ];

  buildInputs = [
    glibcLocales
    gtk3
    keybinder3
    libnotify
    libwnck
    python3
    vte
  ];

  propagatedBuildInputs = with python3Packages; [
    dbus-python
    pycairo
    pygobject3
    setuptools-scm
    pyyaml
    distutils
  ];

  makeFlags = [
    "PREFIX=${placeholder "out"}"
  ];

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ libutempter ]}"
      # For settings migration.
      --prefix PATH : "${lib.makeBinPath [ dconf ]}"
    )
  '';

  build-system = with python3Packages; [
    distutils
  ];

  makeWrapperArgs = [ "--set LOCALE_ARCHIVE ${glibcLocales}/lib/locale/locale-archive" ];
  pyproject = false;
  passthru.tests.test = nixosTests.terminal-emulators.guake;

  meta = {
    description = "Drop-down terminal for GNOME";
    homepage = "http://guake-project.org";
    license = lib.licenses.gpl2Plus;

    maintainers = [
      lib.maintainers.msteen
      lib.maintainers.heywoodlh
    ];

    platforms = lib.platforms.linux;
  };
})
