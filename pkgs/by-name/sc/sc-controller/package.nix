{
  lib,
  fetchFromGitHub,
  bluez,
  gobject-introspection,
  gtk-layer-shell,
  gtk3,
  libappindicator-gtk3,
  librsvg,
  libusb1,
  libx11,
  libxext,
  libxfixes,
  linuxHeaders,
  python3Packages,
  udev,
  udevCheckHook,
  wrapGAppsHook3,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "sc-controller";
  version = "0.5.5";

  src = fetchFromGitHub {
    owner = "C0rn3j";
    repo = "sc-controller";
    tag = "v${finalAttrs.version}";
    hash = "sha256-IQxHa0bR8FWad9v5DfvXHskwayCgzbJm5ekzf1sjfiQ=";
  };

  patches = [ ./scc_osd_keyboard.patch ];

  postPatch = ''
    substituteInPlace scc/paths.py --replace sys.prefix "'$out'"
    substituteInPlace scc/uinput.py --replace /usr/include ${linuxHeaders}/include
    substituteInPlace scc/device_monitor.py --replace "find_library('bluetooth')" "'libbluetooth.so.3'"
  '';

  nativeBuildInputs = [
    wrapGAppsHook3
    gobject-introspection
    udevCheckHook
  ];

  buildInputs = [
    gtk3
    libappindicator-gtk3
    librsvg
  ];

  env.LD_LIBRARY_PATH = lib.makeLibraryPath [
    libx11
    libxext
    libxfixes
    libusb1
    udev
    bluez
  ];

  nativeCheckInputs = [
    python3Packages.pytestCheckHook
    python3Packages.libusb1
    python3Packages.toml
  ];

  doInstallCheck = true;

  preFixup = ''
    gappsWrapperArgs+=(--prefix LD_LIBRARY_PATH : "$LD_LIBRARY_PATH")
  '';

  postFixup = ''
    (
      # scc runs these scripts as programs. (See find_binary() in scc/tools.py.)
      cd $out/lib/python*/site-packages/scc/x11
      patchPythonScript scc-autoswitch-daemon.py
      patchPythonScript scc-osd-daemon.py
    )
  '';

  dependencies =
    with python3Packages;
    [
      evdev
      pygobject3
      pylibacl
      vdf
      ioctl-opt
    ]
    ++ [
      gtk-layer-shell
      python3Packages.libusb1
    ];

  format = "setuptools";

  meta = {
    # donations: https://www.patreon.com/kozec
    description = "User-mode driver and GUI for Steam Controller and other controllers";
    homepage = "https://github.com/C0rn3j/sc-controller";
    license = lib.licenses.gpl2Only;

    maintainers = with lib.maintainers; [
      rnhmjoj
    ];

    platforms = lib.platforms.linux;
  };
})
