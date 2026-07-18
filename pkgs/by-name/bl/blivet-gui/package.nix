# Notes for using this package outside of NixOS:
# 1. --pure cannot be used (as pkexec will be used from the path,
#    and we can't use nixpkgs polkit due to lack of setuid bit)
# 2. You must prefix the blivet-gui command with "SHELL=/bin/bash"
#    (otherwise your system polkit will reject the SHEL Lfrom nixpkgs).

{
  lib,
  fetchFromGitHub,
  adwaita-icon-theme,
  blivet-gui,
  gobject-introspection,
  gtk3,
  hicolor-icon-theme,
  python3,
  testers,
  util-linux,
  wrapGAppsHook3,
  pkexecPath ? "pkexec",
}:

python3.pkgs.buildPythonApplication rec {
  pname = "blivet-gui";
  version = "2.6.0";

  src = fetchFromGitHub {
    owner = "storaged-project";
    repo = "blivet-gui";
    tag = version;
    hash = "sha256-e9YdfFHmKXsbqkzs4++nNlvqm/p6lZmc01A+g+NtuDI=";
  };

  postPatch = ''
    substituteInPlace blivetgui/gui_utils.py --replace-fail /usr/share $out/share
    substituteInPlace blivet-gui --replace-fail "pkexec blivet-gui-daemon" "pkexec $out/bin/blivet-gui-daemon"
    substituteInPlace blivet-gui --replace-fail "pkexec" "${pkexecPath}"
    substituteInPlace blivet-gui.desktop --replace-fail /usr/bin/blivet-gui $out/bin/blivet-gui
    substituteInPlace org.fedoraproject.pkexec.blivet-gui.policy --replace-fail /usr/bin/blivet-gui-daemon $out/bin/blivet-gui-daemon
  '';

  nativeBuildInputs = [
    util-linux
    gobject-introspection
    wrapGAppsHook3
  ];

  buildInputs = [ gtk3 ];

  preFixup = ''
    makeWrapperArgs+=(
      ''${gappsWrapperArgs[@]}
      --prefix XDG_DATA_DIRS : ${adwaita-icon-theme}/share
    )
  '';

  build-system = [
    python3.pkgs.setuptools
  ];

  dependencies = [
    python3.pkgs.blivet
    python3.pkgs.pyparted
    python3.pkgs.pid
  ];

  dontWrapGApps = true;
  pyproject = true;
  passthru.tests.version = testers.testVersion { package = blivet-gui; };

  meta = {
    description = "GUI tool for storage configuration using blivet library";
    homepage = "https://fedoraproject.org/wiki/Blivet";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ cybershadow ];
    platforms = lib.platforms.linux;
    mainProgram = "blivet-gui";
  };
}
