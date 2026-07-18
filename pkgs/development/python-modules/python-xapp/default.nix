{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  gitUpdater,
  gobject-introspection,
  gtk3,
  meson,
  ninja,
  polkit,
  psutil,
  pygobject3,
  xapp,
}:

buildPythonPackage rec {
  pname = "python-xapp";
  version = "3.0.3";

  src = fetchFromGitHub {
    owner = "linuxmint";
    repo = "python-xapp";
    rev = version;
    hash = "sha256-KJ5mzilUg//FvwyhTHjzaUI3661RhN74r5qDIzdDOl8=";
  };

  postPatch = ''
    substituteInPlace "xapp/os.py" \
      --replace-fail "/usr/bin/pkexec" "${polkit}/bin/pkexec"

    # We actually want the localedir provided by the caller.
    substituteInPlace "xapp/util/__init__.py" \
      --replace-fail "/usr/share/locale" "/run/current-system/sw/share/locale"
  '';

  nativeBuildInputs = [
    meson
    ninja
  ];

  propagatedBuildInputs = [
    psutil
    pygobject3
    gtk3
    gobject-introspection
    xapp
    polkit
  ];

  doCheck = false;
  pyproject = false;
  pythonImportsCheck = [ "xapp" ];

  passthru = {
    skipBulkUpdate = true; # This should be bumped as part of Cinnamon update.
    updateScript = gitUpdater { ignoredVersions = "^master.*"; };
  };

  meta = {
    description = "Cross-desktop libraries and common resources for python";
    homepage = "https://github.com/linuxmint/python-xapp";
    license = lib.licenses.lgpl2Plus;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.cinnamon ];
  };
}
