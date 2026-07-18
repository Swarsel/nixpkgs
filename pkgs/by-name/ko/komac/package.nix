{
  lib,
  stdenv,
  fetchFromGitHub,
  bzip2,
  dbus,
  installShellFiles,
  komac,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  testers,
  versionCheckHook,
  zstd,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "komac";
  version = "2.16.0";

  src = fetchFromGitHub {
    owner = "russellbanks";
    repo = "Komac";
    tag = "v${finalAttrs.version}";
    hash = "sha256-joPF92qeK+L+JfPcILbfQQXXOL11hiPDt4JNXouPCK0=";
  };

  nativeBuildInputs = [
    pkg-config
  ]
  ++ lib.optionals (stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
    installShellFiles
  ];

  buildInputs = [
    dbus
    openssl
    zstd
    bzip2
  ];

  cargoHash = "sha256-bmesjvXX++Kn47E+KpHKYF/lpIcNXtVzH4s/AMHDmhc=";

  env = {
    OPENSSL_NO_VENDOR = true;
    YRX_REGENERATE_MODULES_RS = "no";
    ZSTD_SYS_USE_PKG_CONFIG = true;
  };

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd komac \
      --bash <($out/bin/komac complete bash) \
      --zsh <($out/bin/komac complete zsh) \
      --fish <($out/bin/komac complete fish)
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgram = "${placeholder "out"}/bin/komac";

  passthru = {
    tests.version = testers.testVersion {
      inherit (finalAttrs) version;
      command = "komac --version";
      package = komac;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Community Manifest Creator for WinGet";
    homepage = "https://github.com/russellbanks/Komac";
    changelog = "https://github.com/russellbanks/Komac/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      HeitorAugustoLN
      dvdznf
    ];

    mainProgram = "komac";
  };
})
