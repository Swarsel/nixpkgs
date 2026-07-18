{
  lib,
  stdenv,
  fetchFromGitHub,
  bash,
  boehmgc,
  cachix,
  dbus,
  devenv, # required to run version test
  gitMinimal,
  glibcLocalesUtf8,
  installShellFiles,
  libghostty-vt,
  llvmPackages,
  makeBinaryWrapper,
  nixVersions,
  nixd,
  openssl,
  pkg-config,
  protobuf,
  rustPlatform,
  sqlite,
  testers,
}:

let
  version = "2.1.2";
  devenvNixVersion = "2.34";
  devenvNixRev = "42d4b7de21c15f28c568410f4383fa06a8458a40";

  devenvNixSrc = fetchFromGitHub {
    hash = "sha256-g2KEBuHpc3a56c+jPcg0+w6LSuIj6f+zzdztLCOyIhc=";
    name = "devenv-nix-${devenvNixVersion}-source";
    owner = "cachix";
    repo = "nix";
    rev = devenvNixRev;
  };

  nix_components = (nixVersions.nixComponents_git.overrideSource devenvNixSrc).overrideScope (
    finalScope: prevScope: {
      version = devenvNixVersion;
    }
  );
in
rustPlatform.buildRustPackage {
  inherit version;
  pname = "devenv";

  src = fetchFromGitHub {
    owner = "cachix";
    repo = "devenv";
    tag = "v2.1.2";
    hash = "sha256-EQnZCy7r4VMO6KDoytxHBa0mFbM1D9g1kaDfs/s0YZA=";
  };

  nativeBuildInputs = [
    installShellFiles
    makeBinaryWrapper
    pkg-config
    protobuf
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    openssl
    sqlite
    dbus
    libghostty-vt
    llvmPackages.clang-unwrapped
    nix_components.nix-expr-c
    nix_components.nix-store-c
    nix_components.nix-util-c
    nix_components.nix-flake-c
    nix_components.nix-cmd-c
    nix_components.nix-fetchers-c
    nix_components.nix-main-c
  ];

  cargoHash = "sha256-uEwxqnLqCFpyV2NbnfuUyVqKrMeVeQzoGQmElaVeGU8=";

  env = {
    DEVENV_IS_RELEASE = true;
    LIBSQLITE3_SYS_USE_PKG_CONFIG = "1";
    RUSTFLAGS = "--cfg tracing_unstable";
  };

  nativeCheckInputs = [
    gitMinimal
    bash
  ];

  preCheck = ''
    # Initialize git repo for tests that use git-root-relative imports
    pushd $NIX_BUILD_TOP/source
    git init -b main
    git config user.email "test@example.com"
    git config user.name "Test User"
    git add -A
    popd
  '';

  postInstall =
    let
      setDefaultLocaleArchive = lib.optionalString (glibcLocalesUtf8 != null) ''
        --set-default LOCALE_ARCHIVE ${glibcLocalesUtf8}/lib/locale/locale-archive
      '';
    in
    ''
      wrapProgram $out/bin/devenv \
        --prefix PATH ":" "$out/bin:${lib.getBin cachix}/bin:${lib.getBin nixd}/bin" \
        ${setDefaultLocaleArchive}

      wrapProgram $out/bin/devenv-run-tests \
        --prefix PATH ":" "$out/bin:${lib.getBin cachix}/bin:${lib.getBin nixd}/bin" \
        ${setDefaultLocaleArchive}

      # Generate manpages
      cargo xtask generate-manpages --out-dir man
      installManPage man/*

      # Generate shell completions (devenv must be in PATH)
      compdir=./completions
      export PATH="$out/bin:$PATH"
      for shell in bash fish zsh; do
        cargo xtask generate-shell-completion $shell --out-dir $compdir
      done

      installShellCompletion --cmd devenv \
        --bash $compdir/devenv.bash \
        --fish $compdir/devenv.fish \
        --zsh $compdir/_devenv
    '';

  cargoBuildFlags = [
    "-p"
    "devenv"
    "-p"
    "devenv-run-tests"
  ];

  cargoTestFlags = [
    "-p"
    "devenv"
  ];

  useNextest = true;

  passthru.tests = {
    version = testers.testVersion {
      command = "export XDG_DATA_HOME=$PWD; devenv version";
      package = devenv;
    };
  };

  meta = {
    description = "Fast, Declarative, Reproducible, and Composable Developer Environments";
    homepage = "https://github.com/cachix/devenv";
    changelog = "https://github.com/cachix/devenv/releases";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      domenkozar
      sandydoo
    ];

    mainProgram = "devenv";
  };
}
