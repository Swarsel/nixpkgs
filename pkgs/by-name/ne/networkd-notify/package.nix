{
  lib,
  fetchFromGitLab,
  python3Packages,
  systemd,
  wirelesstools,
  wrapGAppsNoGuiHook,
}:

python3Packages.buildPythonApplication {
  pname = "networkd-notify";
  version = "unstable-2022-11-29";

  src = fetchFromGitLab {
    owner = "wavexx";
    repo = "networkd-notify";
    rev = "c2f3e71076a0f51c097064b1eb2505a361c7cc0e";
    hash = "sha256-fanP1EWERT2Jy4OnMo8OMdR9flginYUgMw+XgmDve3o=";
  };

  nativeBuildInputs = [
    wrapGAppsNoGuiHook
  ];

  installPhase = ''
    install -D networkd-notify -t "$out/bin/"
    install -D -m0644 networkd-notify.desktop -t "$out/share/applications/"
  '';

  preFixup = ''
    makeWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  dependencies = with python3Packages; [
    dbus-python
    pygobject3
  ];

  dontBuild = true;
  # Let the Python wrapper add gappsWrapperArgs, to avoid two layers of wrapping.
  dontWrapGApps = true;

  patchPhase = ''
    sed -i \
      -e '/^NETWORKCTL = /c\NETWORKCTL = ["${systemd}/bin/networkctl"]' \
      -e '/^IWCONFIG = /c\IWCONFIG = ["${wirelesstools}/bin/iwconfig"]' \
      networkd-notify
  '';

  # There is no setup.py, just a single Python script.
  pyproject = false;

  meta = {
    description = "Desktop notification integration for systemd-networkd";
    homepage = "https://gitlab.com/wavexx/networkd-notify";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ danc86 ];
    platforms = lib.platforms.linux;
    mainProgram = "networkd-notify";
  };
}
