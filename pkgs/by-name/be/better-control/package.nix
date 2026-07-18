{
  lib,
  fetchFromGitHub,
  bash,
  bluez,
  brightnessctl,
  desktop-file-utils,
  gammastep,
  gobject-introspection,
  gtk3,
  networkmanager,
  nix-update-script,
  power-profiles-daemon,
  pulseaudio,
  python3Packages,
  upower,
  wrapGAppsHook3,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "better-control";
  version = "6.12.1";

  src = fetchFromGitHub {
    owner = "better-ecosystem";
    repo = "better-control";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Dt+se8eOmF8Nzm+/bnYBSIyX0XHSXV9iCPF82qXhzug=";
  };

  nativeBuildInputs = [
    desktop-file-utils
    wrapGAppsHook3
    gobject-introspection
  ];

  buildInputs = [
    bash
    gtk3
  ];

  makeFlags = [ "PREFIX=${placeholder "out"}" ];
  # Project has no tests
  doCheck = false;

  postInstall = ''
    rm $out/bin/betterctl
    chmod +x $out/share/better-control/better_control.py
    substituteInPlace $out/bin/* \
      --replace-fail "python3 " ""
    substituteInPlace $out/share/applications/better-control.desktop \
      --replace-fail "/usr/bin/" ""
  '';

  postFixup = ''
    wrapPythonProgramsIn "$out/share/better-control" "$out ''${pythonPath[*]}"
  '';

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    pygobject3
    dbus-python
    psutil
    qrcode
    requests
    setproctitle
    pillow
    pycairo
  ];

  dontWrapGApps = true;

  makeWrapperArgs = [
    "\${gappsWrapperArgs[@]}"
    "--prefix PATH : ${lib.makeBinPath finalAttrs.runtimeDeps}"
  ];

  pyproject = false;

  # Check src/utils/dependencies.py
  runtimeDeps = [
    pulseaudio
    networkmanager
    bluez
    brightnessctl
    power-profiles-daemon
    gammastep
    upower
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Simple control panel for linux based on GTK";
    homepage = "https://github.com/better-ecosystem/better-control";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ Rishabh5321 ];
    platforms = lib.platforms.linux;
    mainProgram = "control"; # Users use both "control" and "better-control" to launch
  };
})
