{
  lib,
  stdenv,
  fetchFromGitHub,
  capnproto,
  fontconfig,
  installShellFiles,
  llvmPackages,
  nix-update-script,
  openssl,
  pkg-config,
  protobuf,
  rust-jemalloc-sys,
  rustPlatform,
  zlib,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "turbo-unwrapped";
  version = "2.9.18";

  src = fetchFromGitHub {
    owner = "vercel";
    repo = "turborepo";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ugPkWeUJqt1KnGYC85hihHXl3JPlfbTvk4RaLIvVq2Y=";
  };

  nativeBuildInputs = [
    capnproto
    installShellFiles
    pkg-config
    protobuf
  ]
  # https://github.com/vercel/turbo/blob/ea740706e0592b3906ab34c7cfa1768daafc2a84/CONTRIBUTING.md#linux-dependencies
  ++ lib.optional stdenv.hostPlatform.isLinux llvmPackages.bintools;

  buildInputs = [
    fontconfig
    openssl
    rust-jemalloc-sys
    zlib
  ];

  cargoHash = "sha256-LBGaZgW4q//VJfXIqzByQogz0o/fyQcTAAFwlHPuRUc=";

  env = {
    # nightly features are used
    RUSTC_BOOTSTRAP = 1;
  };

  # Browser tests time out with chromium and google-chrome
  doCheck = false;

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd turbo \
      --bash <($out/bin/turbo completion bash) \
      --fish <($out/bin/turbo completion fish) \
      --zsh <($out/bin/turbo completion zsh)
  '';

  cargoBuildFlags = [
    "--package"
    "turbo"
  ];

  passthru = {
    updateScript = nix-update-script {
      extraArgs = [
        "--use-github-releases"
      ];
    };
  };

  meta = {
    description = "High-performance build system for JavaScript and TypeScript codebases";
    homepage = "https://turbo.build/";
    changelog = "https://github.com/vercel/turborepo/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      getchoo
      hythera
    ];

    mainProgram = "turbo";
  };
})
