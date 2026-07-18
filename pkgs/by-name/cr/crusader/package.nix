{
  lib,
  stdenv,
  fetchFromGitHub,
  autoPatchelfHook,
  # buildInputs
  fontconfig,
  libGL,
  libgcc,
  libx11,
  libxcursor,
  libxi,
  libxkbcommon,
  # nativeBuildInputs
  makeWrapper,
  nix-update-script,
  pkg-config,
  rustPlatform,
  versionCheckHook,
  wayland,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "crusader";
  version = "0.3.2";

  src = fetchFromGitHub {
    owner = "Zoxc";
    repo = "crusader";
    tag = "v${finalAttrs.version}";
    hash = "sha256-M5zMOOYDS91p0EuDSlQ3K6eiVQpbX6953q+cXBMix2s=";
  };

  # autoPatchelfHook required on linux for crusader-gui
  nativeBuildInputs = [
    makeWrapper
    pkg-config
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    autoPatchelfHook
  ];

  buildInputs = [
    fontconfig
    libgcc
    libxkbcommon
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    libx11
    libxcursor
    libxi
  ];

  cargoHash = "sha256-f0TWiRX203/gNsa9UEr/1Bv+kUxLAK/Zlw+S693xZlE=";
  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  postFixup = ''
    # the program looks for libwayland-client.so at runtime
    wrapProgram $out/bin/crusader-gui \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ wayland ]}
  '';

  # required for crusader-gui
  runtimeDependencies = [
    libGL
    libxkbcommon
  ];

  sourceRoot = "${finalAttrs.src.name}/src";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Network throughput and latency tester";
    homepage = "https://github.com/Zoxc/crusader";
    changelog = "https://github.com/Zoxc/crusader/blob/v${finalAttrs.version}/CHANGELOG.md";

    license = with lib.licenses; [
      mit
      asl20
    ];

    maintainers = with lib.maintainers; [ x123 ];
    platforms = lib.platforms.all;
    mainProgram = "crusader";
  };
})
