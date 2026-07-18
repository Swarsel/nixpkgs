{
  lib,
  fetchFromGitHub,
  python3Packages,
  qt5,
  wrapGAppsHook3,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "buttermanager";
  version = "2.5.2";

  src = fetchFromGitHub {
    owner = "egara";
    repo = "buttermanager";
    tag = finalAttrs.version;
    hash = "sha256-/U5IVJvYCw/YzBWjQ949YP9uoxsTNRJ5FO7rrI6Cvhs=";
  };

  nativeBuildInputs = [
    wrapGAppsHook3
    qt5.wrapQtAppsHook
  ];

  propagatedBuildInputs = with python3Packages; [
    pyqt5
    pyyaml
    sip
    tkinter
  ];

  postInstall = ''
    substituteInPlace packaging/buttermanager.desktop \
      --replace-fail /opt/buttermanager/gui/buttermanager.svg buttermanager

    install -Dm444 packaging/buttermanager.desktop -t $out/share/applications
    install -Dm444 packaging/buttermanager.svg -t $out/share/icons/hicolor/scalable/apps
  '';

  dontWrapGApps = true;
  dontWrapQtApps = true;

  makeWrapperArgs = [
    "\${qtWrapperArgs[@]}"
    "\${gappsWrapperArgs[@]}"
  ];

  pyproject = true;

  meta = {
    description = "Btrfs tool for managing snapshots, balancing filesystems and upgrading the system safetly";
    homepage = "https://github.com/egara/buttermanager";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ t4ccer ];
    mainProgram = "buttermanager";
  };
})
