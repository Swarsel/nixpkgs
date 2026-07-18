{
  lib,
  fetchFromGitHub,
  installShellFiles,
  pkg-config,
  rustPlatform,
  wayland,
  withNativeLibs ? false,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "wl-clipboard-rs";
  version = "0.9.3";

  src = fetchFromGitHub {
    owner = "YaLTeR";
    repo = "wl-clipboard-rs";
    rev = "v${finalAttrs.version}";
    hash = "sha256-eUD3XmEiBVMf+bImG6Ah48/96AxFhqTiLjK1gPJFdpw=";
  };

  nativeBuildInputs = [
    installShellFiles
  ]
  ++ lib.optionals withNativeLibs [
    pkg-config
  ];

  buildInputs = [
    installShellFiles
  ]
  ++ lib.optionals withNativeLibs [
    wayland
  ];

  cargoHash = "sha256-yTQ4EZ8ae3v0H4C94lV6AVNVSi+XDroKxjjHU4MagGU=";

  # Assertion errors
  checkFlags = [
    "--skip=tests::copy::copy_large"
    "--skip=tests::copy::copy_multi_no_additional_text_mime_types_test"
    "--skip=tests::copy::copy_multi_test"
    "--skip=tests::copy::copy_randomized"
    "--skip=tests::copy::copy_test"
  ];

  preCheck = ''
    export XDG_RUNTIME_DIR=$(mktemp -d)
  '';

  postInstall = ''
    installManPage target/man/wl-copy.1
    installManPage target/man/wl-paste.1

    installShellCompletion --cmd wl-copy \
      --bash target/completions/wl-copy.bash \
      --fish target/completions/wl-copy.fish \
      --zsh target/completions/_wl-copy

    installShellCompletion --cmd wl-paste \
      --bash target/completions/wl-paste.bash \
      --fish target/completions/wl-paste.fish \
      --zsh target/completions/_wl-paste
  '';

  cargoBuildFlags = [
    "--package=wl-clipboard-rs"
    "--package=wl-clipboard-rs-tools"
  ]
  ++ lib.optionals withNativeLibs [
    "--features=native_lib"
  ];

  meta = {
    description = "Command-line copy/paste utilities for Wayland, written in Rust";
    homepage = "https://github.com/YaLTeR/wl-clipboard-rs";
    changelog = "https://github.com/YaLTeR/wl-clipboard-rs/blob/v${finalAttrs.version}/CHANGELOG.md";

    license = with lib.licenses; [
      asl20
      mit
    ];

    maintainers = with lib.maintainers; [
      donovanglover
    ];

    platforms = lib.platforms.linux;
    mainProgram = "wl-clip";
  };
})
