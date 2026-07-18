{
  lib,
  stdenv,
  cmake,
  fetchFromSourcehut,
  gitUpdater,
  libusb1,
  pkg-config,
  qt6,
  enableGUI ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "heimdall";
  version = "2.2.2";

  src = fetchFromSourcehut {
    owner = "~grimler";
    repo = "Heimdall";
    rev = "v${finalAttrs.version}";
    hash = "sha256-ga2hAZhsKosEG//qXEf+1vhJYtsHwyq6QvMlZaSFIgQ=";
  };

  outputs = [
    "out"
    "udev"
  ];

  patches = [
    ./0001-Install-the-macOS-bundle-to-the-install-prefix.patch
  ];

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    pkg-config
  ]
  ++ lib.optional enableGUI qt6.wrapQtAppsHook;

  buildInputs = [
    (libusb1.override { withStatic = stdenv.hostPlatform.isWindows; })
  ]
  ++ lib.optional enableGUI qt6.qtbase;

  cmakeFlags = [
    (lib.cmakeBool "DISABLE_FRONTEND" (!enableGUI))
  ];

  preInstall = ''
    mkdir -p $udev/lib/udev/rules.d
    install -m644 -t $udev/lib/udev/rules.d $src/heimdall/60-heimdall.rules
  '';

  doInstallCheck = true;

  # heimdall cli looked up from PATH by gui
  preFixup = lib.optional enableGUI ''
    qtWrapperArgs+=(--prefix PATH : "$out/bin")
  '';

  passthru.updateScript = gitUpdater { rev-prefix = "v"; };

  meta = {
    description = "Cross-platform open-source tool suite used to flash firmware onto Samsung Galaxy devices";
    homepage = "https://git.sr.ht/~grimler/Heimdall";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      surfaceflinger
      timschumi
    ];

    platforms = with lib.platforms; unix ++ windows;

    mainProgram =
      (if enableGUI then "heimdall-frontend" else "heimdall")
      + lib.optionalString stdenv.hostPlatform.isWindows ".exe";
  };
})
