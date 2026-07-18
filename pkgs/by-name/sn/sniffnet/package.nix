{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  expat,
  fontconfig,
  # buildInputs
  libpcap,
  libx11,
  libxcursor,
  libxi,
  # wrapper
  libxkbcommon,
  libxrandr,
  openssl,
  # nativeBuildInputs
  pkg-config,
  rustPlatform,
  # tests
  versionCheckHook,
  vulkan-loader,
  wayland,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "sniffnet";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "gyulyvgc";
    repo = "sniffnet";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ifXccpoyz+NnZDjbRXlVZXfd2TLvOhGVB504hDyIjnE=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libpcap
    openssl
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    alsa-lib
    expat
    fontconfig
    vulkan-loader
    libx11
    libxcursor
    libxi
    libxrandr
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    rustPlatform.bindgenHook
  ];

  cargoHash = "sha256-Tw32dOzFkO/cOlLdTfHeybhmbidgsnfYMIeHhfrrtVc=";

  # requires internet access
  checkFlags = [
    "--skip=secondary_threads::check_updates::tests::fetch_latest_release_from_github"
    "--skip=utils::check_updates::tests::fetch_latest_release_from_github"
  ];

  postInstall = ''
    for res in $(ls resources/packaging/linux/graphics | sed -e 's/sniffnet_//g' -e 's/x.*//g'); do
      install -Dm444 resources/packaging/linux/graphics/sniffnet_''${res}x''${res}.png \
        $out/share/icons/hicolor/''${res}x''${res}/apps/sniffnet.png
    done
    install -Dm444 resources/packaging/linux/sniffnet.desktop -t $out/share/applications
    substituteInPlace $out/share/applications/sniffnet.desktop \
      --replace 'Exec=/usr/bin/sniffnet' 'Exec=sniffnet'
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  postFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
    patchelf $out/bin/sniffnet \
      --add-rpath ${
        lib.makeLibraryPath [
          vulkan-loader
          libx11
          libxkbcommon
          wayland
        ]
      }
  '';

  meta = {
    description = "Cross-platform application to monitor your network traffic with ease";
    homepage = "https://github.com/gyulyvgc/sniffnet";
    changelog = "https://github.com/gyulyvgc/sniffnet/blob/v${finalAttrs.version}/CHANGELOG.md";

    license = with lib.licenses; [
      mit # or
      asl20
    ];

    maintainers = [ ];
    mainProgram = "sniffnet";
    teams = [ lib.teams.ngi ];
  };
})
