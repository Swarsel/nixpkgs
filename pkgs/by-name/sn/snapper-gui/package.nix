{
  lib,
  fetchFromGitHub,
  adwaita-icon-theme,
  gobject-introspection,
  gtk3,
  gtksourceview3,
  nix-update-script,
  python3,
  python3Packages,
  snapper,
  wrapGAppsHook3,
}:

python3Packages.buildPythonApplication {
  pname = "snapper-gui";
  version = "0.1-unstable-2022-06-26";

  src = fetchFromGitHub {
    owner = "ricardomv";
    repo = "snapper-gui";
    rev = "191575084a4e951802c32a4177dc704cf435883a";
    sha256 = "sha256-uy1oLJx4ERGc8OHzmPpnJX81jPB9ztrA0qbmm1UcmTY=";
  };

  nativeBuildInputs = [
    wrapGAppsHook3
    gobject-introspection
  ];

  buildInputs = [
    python3
    adwaita-icon-theme
  ];

  propagatedBuildInputs = with python3Packages; [
    gtk3
    dbus-python
    pygobject3
    setuptools
    gtksourceview3
    snapper
  ];

  doCheck = false; # it doesn't have any tests
  format = "setuptools";

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version=branch" ];
  };

  meta = {
    description = "Graphical interface for snapper";

    longDescription = ''
      A graphical user interface for the tool snapper for Linux filesystem
      snapshot management. It can compare snapshots and revert differences between snapshots.
      In simple terms, this allows root and non-root users to view older versions of files
      and revert changes. Currently works with btrfs, ext4 and thin-provisioned LVM volumes.
    '';

    homepage = "https://github.com/ricardomv/snapper-gui";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ ahuzik ];
    platforms = lib.platforms.linux;
    mainProgram = "snapper-gui";
  };
}
