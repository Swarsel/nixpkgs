{
  lib,
  stdenv,
  cargo-auditable,
  cmake,
  curl,
  file,
  installShellFiles,
  makeWrapper,
  openssl,
  pkg-config,
  pkgsBuildBuild,
  pkgsHostHost,
  python3,
  rustPlatform,
  rustc,
  zlib,
  auditable ? !cargo-auditable.meta.broken,
}:

rustPlatform.buildRustPackage.override
  {
    cargo-auditable = cargo-auditable.bootstrap;
  }
  {
    inherit (rustc.unwrapped) version src;
    inherit auditable;
    pname = "cargo";

    nativeBuildInputs = [
      pkg-config
      cmake
      installShellFiles
      makeWrapper
      (lib.getDev pkgsHostHost.curl)
      zlib
    ];

    buildInputs = [
      file
      curl
      python3
      openssl
      zlib
    ];

    env = {
      # cargo uses git-rs which is made for a version of libgit2 from recent master that
      # is not compatible with the current version in nixpkgs.
      #LIBGIT2_SYS_USE_PKG_CONFIG = 1;

      # fixes: the cargo feature `edition` requires a nightly version of Cargo, but this is the `stable` channel
      RUSTC_BOOTSTRAP = 1;

    }
    // lib.optionalAttrs (stdenv.hostPlatform.rust.rustcTargetSpec == "x86_64-unknown-linux-gnu") {
      # Upstream defaults to lld on x86_64-unknown-linux-gnu, we want to use our linker
      RUSTFLAGS = "-Clinker-features=-lld -Clink-self-contained=-linker";
    };

    # Disable check phase as there are failures (4 tests fail)
    doCheck = false;

    checkPhase = ''
      # Disable cross compilation tests
      export CFG_DISABLE_CROSS_TESTS=1
      cargo test
    '';

    postInstall = ''
      wrapProgram "$out/bin/cargo" --suffix PATH : "${rustc}/bin"

      installManPage src/tools/cargo/src/etc/man/*

    ''
    + (
      if stdenv.buildPlatform.canExecute stdenv.hostPlatform then
        ''
          installShellCompletion --cmd cargo \
            --bash <(CARGO_COMPLETE=bash cargo) \
            --fish <(CARGO_COMPLETE=fish cargo) \
            --zsh <(CARGO_COMPLETE=zsh cargo)
        ''
      else
        ''
          installShellCompletion --cmd cargo \
            --bash src/tools/cargo/src/etc/cargo.bashcomp.sh \
            --fish ${pkgsBuildBuild.cargo}/share/fish/vendor_completions.d/*.fish \
            --zsh src/tools/cargo/src/etc/_cargo
        ''
    );

    doInstallCheck = !stdenv.hostPlatform.isStatic && stdenv.hostPlatform.isElf;

    installCheckPhase = ''
      runHook preInstallCheck
      ${stdenv.cc.targetPrefix}readelf -a $out/bin/.cargo-wrapped | grep -F 'Shared library: [libcurl.so'
      runHook postInstallCheck
    '';

    buildAndTestSubdir = "src/tools/cargo";
    # the rust source tarball already has all the dependencies vendored, no need to fetch them again
    cargoVendorDir = "vendor";
    # changes hash of vendor directory otherwise
    dontUpdateAutotoolsGnuConfigScripts = true;

    passthru = {
      inherit (rustc.unwrapped) tests;
      rustc = rustc;
    };

    meta = {
      description = "Downloads your Rust project's dependencies and builds your project";
      homepage = "https://crates.io";

      license = [
        lib.licenses.mit
        lib.licenses.asl20
      ];

      platforms = lib.platforms.unix;
      mainProgram = "cargo";
      # https://github.com/alexcrichton/nghttp2-rs/issues/2
      broken = stdenv.hostPlatform.isx86 && stdenv.buildPlatform != stdenv.hostPlatform;
      teams = [ lib.teams.rust ];
    };
  }
