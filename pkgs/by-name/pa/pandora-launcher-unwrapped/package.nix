{
  lib,
  stdenv,
  fetchFromGitHub,
  addDriverRunpath,
  alsa-lib,
  apple-sdk_15,
  copyDesktopItems,
  dbus,
  fontconfig,
  imagemagick,
  libGL,
  libseccomp,
  libxcb,
  libxkbcommon,
  makeDesktopItem,
  openssl,
  patchelf,
  pkg-config,
  rustPlatform,
  vulkan-loader,
  wayland,
  msaClientID ? null,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "pandora-launcher-unwrapped";
  version = "5.3.0";

  src = fetchFromGitHub {
    owner = "Moulberry";
    repo = "PandoraLauncher";
    tag = "v${finalAttrs.version}";
    hash = "sha256-L8rUjbCrAV6D0HIKUzONYS9kY5rz2JLNzXg50u4GPJQ=";
  };

  # Currently the client id is hardcoded and must be patched like this.
  postPatch = lib.optionalString (msaClientID != null) ''
    substituteInPlace crates/auth/src/constants.rs \
      --replace-fail \
      'pub const CLIENT_ID: &str = "e5226706-5096-431d-9516-ae48fe263401";' \
      'pub const CLIENT_ID: &str = "${msaClientID}";'
  '';

  strictDeps = true;

  nativeBuildInputs = [
    rustPlatform.bindgenHook
    copyDesktopItems

    imagemagick
    patchelf
    pkg-config
  ];

  buildInputs = [
    fontconfig
    openssl
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    alsa-lib
    dbus
    libseccomp
    libxcb
    libxkbcommon
    wayland
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    apple-sdk_15
  ];

  env.OPENSSL_NO_VENDOR = true;
  doCheck = false; # there aren't any tests

  postInstall = ''
    for size in 16 24 32 48 64 128 256; do
      geometry="$size"x"$size"
      mkdir -p "$out/share/icons/hicolor/$geometry/apps"
      magick package/windows.svg -resize "$geometry" \
        "$out/share/icons/hicolor/$geometry/apps/pandora_launcher.png"
    done
  '';

  doInstallCheck = true;

  installCheckPhase =
    let
      expectedOutput = builtins.toFile "pandora-launcher-help-expected" ''
        Usage: pandora_launcher [OPTIONS]

        Options:
              --run-instance <RUN_INSTANCE>  Instance to launch, instead of opening the launcher
          -h, --help                         Print help
      '';
    in
    ''
      runHook preInstallCheck

      diff <($out/bin/pandora_launcher --help) ${expectedOutput}

      runHook postInstallCheck
    '';

  postFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
    patchelf --add-rpath "${addDriverRunpath.driverLink}/lib:${
      lib.makeLibraryPath [
        libGL
        vulkan-loader
        wayland
      ]
    }" $out/bin/pandora_launcher
  '';

  __structuredAttrs = true;
  cargoVendorDir = "vendor"; # everything is vendored in-tree

  desktopItems = lib.singleton (makeDesktopItem {
    desktopName = "Pandora Launcher";
    exec = "pandora_launcher";
    genericName = "Unofficial Minecraft Launcher";
    icon = "pandora_launcher";
    name = "com.moulberry.pandoralauncher";
  });

  dontCargoSetupPostUnpack = true;
  dontUpdateAutotoolsGnuConfigScripts = true; # will modify vendor dir, which cargo doesn't allow

  meta = {
    description = "Minecraft launcher that balances ease-of-use with powerful instance management features";
    homepage = "https://github.com/Moulberry/PandoraLauncher";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      dtomvan
      eveeifyeve
    ];

    mainProgram = "pandora_launcher";
  };
})
