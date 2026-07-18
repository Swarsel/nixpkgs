{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPackages,
  gitMinimal,
  installShellFiles,
  llvmPackages,
  nixosTests,
  rustPlatform,
  tzdata,
  writableTmpDirAsHomeHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "starship";
  version = "1.26.0";

  src = fetchFromGitHub {
    owner = "starship";
    repo = "starship";
    tag = "v${finalAttrs.version}";
    hash = "sha256-pStNE8SMMVavL3ld6RO+5QQRJPXpqlU3asccS2tUoMQ=";
  };

  nativeBuildInputs = [
    installShellFiles
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ llvmPackages.lld ];

  buildInputs = lib.optionals (stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64) [
    writableTmpDirAsHomeHook
  ];

  cargoHash = "sha256-IO/H75FKU3/2oAJ8AKerGujMDfun8w4fV7gETMxWOt0=";

  env = {
    TZDIR = "${tzdata}/share/zoneinfo";
  }
  // lib.optionalAttrs stdenv.hostPlatform.isDarwin {
    # Work around ld64's libc++ hardening issue.
    #
    # TODO: Remove once #536365 reaches this branch.
    NIX_CFLAGS_LINK = "-fuse-ld=lld";
  };

  nativeCheckInputs = [
    gitMinimal
    writableTmpDirAsHomeHook
  ];

  postInstall = ''
    presetdir=$out/share/starship/presets/
    mkdir -p $presetdir
    cp docs/public/presets/toml/*.toml $presetdir
  ''
  + lib.optionalString (stdenv.hostPlatform.emulatorAvailable buildPackages) (
    let
      emulator = stdenv.hostPlatform.emulator buildPackages;
    in
    ''
      installShellCompletion --cmd starship \
        --bash <(${emulator} $out/bin/starship completions bash) \
        --fish <(${emulator} $out/bin/starship completions fish) \
        --zsh <(${emulator} $out/bin/starship completions zsh)
    ''
  );

  passthru.tests = {
    inherit (nixosTests) starship;
  };

  meta = {
    description = "Minimal, blazing fast, and extremely customizable prompt for any shell";
    homepage = "https://starship.rs";
    changelog = "https://github.com/starship/starship/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.isc;

    maintainers = with lib.maintainers; [
      Frostman
      da157
      sigmasquadron
    ];

    mainProgram = "starship";
    downloadPage = "https://github.com/starship/starship";
  };
})
