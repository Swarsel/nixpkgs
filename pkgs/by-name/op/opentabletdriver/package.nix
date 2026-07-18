{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  copyDesktopItems,
  coreutils,
  dotnetCorePackages,
  gtk3,
  jq,
  libappindicator,
  libevdev,
  libnotify,
  libx11,
  libxrandr,
  makeDesktopItem,
  nix-update-script,
  nixosTests,
  udev,
  udevCheckHook,
  versionCheckHook,
  wrapGAppsHook3,
}:

buildDotnetModule (finalAttrs: {
  pname = "OpenTabletDriver";
  version = "0.6.7";

  src = fetchFromGitHub {
    owner = "OpenTabletDriver";
    repo = "OpenTabletDriver";
    tag = "v${finalAttrs.version}";
    hash = "sha256-jL3d1DjY9n85BrO6ajZVvJMHmPYfxng4YE25s/9hfGA=";
  };

  nativeBuildInputs = [
    copyDesktopItems
    wrapGAppsHook3
    udevCheckHook
    # Dependency of generate-rules.sh
    jq
  ];

  buildInputs = finalAttrs.runtimeDeps;
  env.OTD_CONFIGURATIONS = "${finalAttrs.src}/OpenTabletDriver.Configurations/Configurations";

  preBuild = ''
    patchShebangs generate-rules.sh
    substituteInPlace generate-rules.sh \
      --replace-fail '/usr/bin/env rm' '${lib.getExe' coreutils "rm"}'
  '';

  doCheck = true;
  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  postFixup = ''
    # Give a more "*nix" name to the binaries
    mv $out/bin/OpenTabletDriver.Console $out/bin/otd
    mv $out/bin/OpenTabletDriver.Daemon $out/bin/otd-daemon
    mv $out/bin/OpenTabletDriver.UX.Gtk $out/bin/otd-gui

    install -Dm644 $src/OpenTabletDriver.UX/Assets/otd.png -t $out/share/icons

    # Generate udev rules from source
    mkdir -p $out/lib/udev/rules.d
    ./generate-rules.sh > $out/lib/udev/rules.d/70-opentabletdriver.rules

    wrapProgram $out/bin/otd-gui \
      "''${gappsWrapperArgs[@]}" \
      --add-flags --skipupdate
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Utility" ];
      comment = "Open source, cross-platform, user-mode tablet driver";
      desktopName = "OpenTabletDriver";
      exec = "otd-gui";
      icon = "otd";
      name = "OpenTabletDriver";
    })
  ];

  disabledTests = [
    # Require networking & unused in Linux build
    "OpenTabletDriver.Tests.UpdaterTests.CheckForUpdates_Returns_Update_When_Available"
    "OpenTabletDriver.Tests.UpdaterTests.Install_Throws_UpdateAlreadyInstalledException_When_AlreadyInstalled"
    "OpenTabletDriver.Tests.UpdaterTests.Install_DoesNotThrow_UpdateAlreadyInstalledException_When_PreviousInstallFailed"
    "OpenTabletDriver.Tests.UpdaterTests.Install_Throws_UpdateInProgressException_When_AnotherUpdate_Is_InProgress"
    "OpenTabletDriver.Tests.UpdaterTests.Install_Moves_UpdatedBinaries_To_BinDirectory"
    "OpenTabletDriver.Tests.UpdaterTests.Install_Moves_Only_ToBeUpdated_Binaries"
    "OpenTabletDriver.Tests.UpdaterTests.Install_Copies_AppDataFiles"
    # Depends on processor load
    "OpenTabletDriver.Tests.TimerTests.TimerAccuracy"
  ];

  dontWrapGApps = true;
  dotnet-sdk = dotnetCorePackages.sdk_8_0;

  executables = [
    "OpenTabletDriver.Console"
    "OpenTabletDriver.Daemon"
    "OpenTabletDriver.UX.Gtk"
  ];

  nugetDeps = ./deps.json;

  projectFile = [
    "OpenTabletDriver.Console"
    "OpenTabletDriver.Daemon"
    "OpenTabletDriver.UX.Gtk"
  ];

  runtimeDeps = [
    gtk3
    libappindicator
    libevdev
    libnotify
    libx11
    libxrandr
    udev
  ];

  testProjectFile = "OpenTabletDriver.Tests/OpenTabletDriver.Tests.csproj";
  versionCheckProgram = "${placeholder "out"}/bin/otd-daemon";

  passthru = {
    tests = {
      otd-runs = nixosTests.opentabletdriver;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Open source, cross-platform, user-mode tablet driver";
    homepage = "https://github.com/OpenTabletDriver/OpenTabletDriver";
    changelog = "https://github.com/OpenTabletDriver/OpenTabletDriver/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.lgpl3Plus;

    maintainers = with lib.maintainers; [
      gepbird
      thiagokokada
    ];

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];

    mainProgram = "otd";
  };
})
