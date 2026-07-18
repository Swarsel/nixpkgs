{
  lib,
  stdenv,
  fetchFromGitHub,
  gitUpdater,
  glib,
  gobject-introspection,
  gspell,
  gtk3,
  meson,
  ninja,
  python3,
  wrapGAppsHook3,
  xapp,
  xapp-symbolic-icons,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sticky";
  version = "1.31";

  src = fetchFromGitHub {
    owner = "linuxmint";
    repo = "sticky";
    rev = finalAttrs.version;
    hash = "sha256-OPn3SNHeHQ3rw71R3oqV3DHxRPq4Ta+qxwkYeegVxbU=";
  };

  postPatch = ''
    sed -i -e "s|/usr/lib|$out/lib|" usr/bin/sticky
    sed -i -e "s|/usr/share|$out/share|" usr/lib/sticky/*.py
  '';

  nativeBuildInputs = [
    gobject-introspection
    meson
    ninja
    python3.pkgs.wrapPython
    wrapGAppsHook3
  ];

  buildInputs = [
    xapp
    glib
    gspell
    gtk3
    python3 # for patchShebangs
  ];

  preFixup = ''
    buildPythonPath "$out ''${pythonPath[*]}"

    gappsWrapperArgs+=(
      --prefix PYTHONPATH : "$program_PYTHONPATH"
      --prefix XDG_DATA_DIRS : "${lib.makeSearchPath "share" [ xapp-symbolic-icons ]}"
    )
  '';

  pythonPath = with python3.pkgs; [
    pygobject3
    python-xapp
  ];

  passthru = {
    updateScript = gitUpdater {
      ignoredVersions = "master.*";
    };
  };

  meta = {
    description = "Sticky notes app for the Linux desktop";
    homepage = "https://github.com/linuxmint/sticky";
    license = lib.licenses.gpl2Only;

    maintainers = with lib.maintainers; [
      linsui
      bobby285271
    ];

    platforms = lib.platforms.linux;
    mainProgram = "sticky";
  };
})
