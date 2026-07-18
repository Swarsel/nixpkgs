{
  lib,
  stdenv,
  fetchFromGitHub,
  autoAddDriverRunpath,
  bashNonInteractive,
  clinfo,
  coreutils,
  fuse3,
  gdk-pixbuf,
  gtk4,
  hwdata,
  libadwaita,
  libdisplay-info,
  libdrm,
  nix-update-script,
  nixosTests,
  ocl-icd,
  pkg-config,
  rustPlatform,
  systemdMinimal,
  vulkan-loader,
  vulkan-tools,
  wrapGAppsHook4,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "lact";
  version = "0.9.1";

  src = fetchFromGitHub {
    owner = "ilya-zlobintsev";
    repo = "LACT";
    tag = "v${finalAttrs.version}";
    hash = "sha256-/b5Cfexi/RtE3DkON5J3dc4aEX6aLZvIcAhsg6Kdv7M=";
  };

  postPatch = ''
    substituteInPlace lact-daemon/src/server/handler.rs \
      --replace-fail 'run_command("journalctl",'  'run_command("${systemdMinimal}/bin/journalctl",'

    substituteInPlace lact-daemon/src/server/handler.rs \
      --replace-fail 'Command::new("sh")' 'Command::new("${bashNonInteractive}/bin/bash")'

    substituteInPlace lact-daemon/src/server/handler.rs \
      --replace-fail 'Command::new("clinfo")' 'Command::new("${clinfo}/bin/clinfo")'

    substituteInPlace lact-daemon/src/server/vulkan.rs \
      --replace-fail 'Command::new("vulkaninfo")' 'Command::new("${vulkan-tools}/bin/vulkaninfo")'

    substituteInPlace lact-daemon/src/server/opencl.rs \
      --replace-fail 'Command::new("clinfo")' 'Command::new("${clinfo}/bin/clinfo")'


    substituteInPlace lact-daemon/src/socket.rs \
      --replace-fail 'run_command("chown"' 'run_command("${coreutils}/bin/chown"'

    substituteInPlace res/lactd.service \
      --replace-fail ExecStart={lact,$out/bin/lact}

    # read() looks for the database in /usr/share so we use read_from_file() instead
    substituteInPlace lact-daemon/src/server/handler.rs \
      --replace-fail 'Database::read()' 'Database::read_from_file("${hwdata}/share/hwdata/pci.ids")'
  '';

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook4
    rustPlatform.bindgenHook
    autoAddDriverRunpath
  ];

  buildInputs = [
    gdk-pixbuf
    gtk4
    libadwaita
    libdisplay-info
    libdrm
    ocl-icd
    vulkan-loader
    vulkan-tools
    hwdata
    fuse3
  ];

  cargoHash = "sha256-XV37VRbCaxySMgEqXmIA0TUpI9uR+6jGOzdMlEfWxDw=";

  # we do this here so that the binary is usable during integration tests
  env.RUSTFLAGS = lib.optionalString stdenv.targetPlatform.isElf (
    lib.concatStringsSep " " [
      "-C link-arg=-Wl,-rpath,${
        lib.makeLibraryPath [
          vulkan-loader
          libdrm
          ocl-icd
        ]
      }"
      "-C link-arg=-Wl,--add-needed,${vulkan-loader}/lib/libvulkan.so"
      "-C link-arg=-Wl,--add-needed,${libdrm}/lib/libdrm.so"
      "-C link-arg=-Wl,--add-needed,${ocl-icd}/lib/libOpenCL.so"
    ]
  );

  checkFlags = [
    # Requires /dev/fuse, which is unavailable in the Nix build sandbox.
    "--skip=tests::apply_settings"
  ];

  postInstall = ''
    install -Dm444 res/lactd.service -t $out/lib/systemd/system
    install -Dm444 res/io.github.ilya_zlobintsev.LACT.desktop -t $out/share/applications
    install -Dm444 res/io.github.ilya_zlobintsev.LACT.svg -t $out/share/icons/hicolor/scalable/apps
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix PATH : "${lib.makeBinPath [ vulkan-tools ]}"
    )
  '';

  postFixup = lib.optionalString stdenv.targetPlatform.isElf ''
    patchelf $out/bin/.lact-wrapped \
    --add-needed libvulkan.so \
    --add-needed libdrm.so \
    --add-needed libOpenCL.so \
    --add-rpath ${
      lib.makeLibraryPath [
        vulkan-loader
        libdrm
        ocl-icd
      ]
    }
  '';

  passthru.tests = {
    inherit (nixosTests) lact;
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Linux GPU Configuration Tool for AMD and NVIDIA";
    homepage = "https://github.com/ilya-zlobintsev/LACT";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      atemu
      cything
      johnrtitor
    ];

    platforms = lib.platforms.linux;
    mainProgram = "lact";
  };
})
