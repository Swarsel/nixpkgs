{
  lib,
  stdenv,
  fetchFromGitHub,
  apple-sdk_15,
  cargo,
  deno,
  glib,
  glibc,
  gn,
  icu,
  libffi,
  ninja,
  pkg-config,
  python3,
  rust-bindgen,
  rustPlatform,
  rustc,
  rustfmt,
  symlinkJoin,
  xcbuild,
  llvmPackages ? rustc.llvmPackages,
}:
let
  rustToolchain = symlinkJoin {
    name = "rusty-v8-rust-toolchain";

    paths = [
      rustc
      rust-bindgen
      rustfmt
      cargo
      llvmPackages.libclang.lib
      # To provide about the same tools as the upstream rust toolchain, the following inputs are also needed.
      # But they are not actually needed, and to avoid unnecessary rebuilds, we are not adding them.
      #rustc-unwrapped
      #rust-analyzer
      #clippy
    ];
    /*
      postBuild = ''
        mkdir -p "$out/lib/rustlib/src/rust"
        cp -r '${rustPlatform.rustcSrc}'/* "$out/lib/rustlib/src/rust/"
        chmod u+w "$out/lib/rustlib/src/rust/library/"
        ln -s '${rustPlatform.rustVendorSrc}' "$out/lib/rustlib/src/rust/library/vendor"
      '';
    */
  };

  clangBasePath = symlinkJoin {
    postBuild =
      if stdenv.targetPlatform.isDarwin then
        ''
          dir="$out/lib/clang/${lib.versions.major llvmPackages.clang.version}/lib/darwin/"
          mkdir -p "$dir"
          ln -s ${llvmPackages.compiler-rt}/lib/darwin/libclang_rt.osx* "$dir/libclang_rt.osx${stdenv.hostPlatform.extensions.staticLibrary}"
        ''
      else
        ''
          dir="$out/lib/clang/${lib.versions.major llvmPackages.clang.version}/lib/${stdenv.hostPlatform.config}/"
          mkdir -p "$dir"
          ln -s ${llvmPackages.compiler-rt}/lib/linux/libclang_rt.builtins-* "$dir/libclang_rt.builtins${stdenv.hostPlatform.extensions.staticLibrary}"
        '';

    name = "rusty-v8-llvm-toolchain";

    paths = [
      llvmPackages.clang-unwrapped.lib
      llvmPackages.clang
      llvmPackages.llvm
      llvmPackages.lld
    ];
  };
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rusty-v8";
  version = "149.4.0";

  src = fetchFromGitHub {
    owner = "denoland";
    repo = "rusty_v8";
    tag = "v${finalAttrs.version}";
    hash = "sha256-n4dKtki9ov0lWBeLmMDI4Tpk8zQ8YYSf04QW6DTYisY=";
    fetchSubmodules = true;
  };

  patches = [
    ./librusty_v8_no_downloads.patch
    ./llvm22.patch
    ./gn_inputs_fix.patch
  ]
  ++ lib.optionals stdenv.targetPlatform.isDarwin [
    ./librusty_v8-darwin-fix-__rust_no_alloc_shim_is_unstable_v2.patch
  ];

  postPatch = ''
    ln -sv ${rustToolchain} third_party/rust-toolchain
  '';

  nativeBuildInputs = [
    llvmPackages.clang
    python3
    pkg-config
    llvmPackages.lld
  ]
  ++ lib.optionals stdenv.targetPlatform.isLinux [
    glibc
  ]
  ++ lib.optionals stdenv.targetPlatform.isDarwin [
    xcbuild
  ];

  buildInputs = [
    glib
    icu
    libffi
  ]
  ++ lib.optionals stdenv.targetPlatform.isDarwin [
    apple-sdk_15
  ];

  cargoHash = "sha256-bGqg/6sfBaF/JpObgXyP4Mh+4P9zfuzd454m4wjluGw=";

  env = {
    CLANG_BASE_PATH = clangBasePath;

    EXTRA_GN_ARGS = lib.concatStringsSep " " (
      [
        "use_system_libffi=true"
        "use_sysroot=false" # prevent download of debian sysroot
        "clang_version=\"${lib.versions.major llvmPackages.clang.version}\""
        "rustc_version=\"${rustc.version}\""
        "rust_sysroot_absolute=\"${rustToolchain}\""
        "rust_bindgen_root=\"${rustToolchain}\""
      ]
      ++ lib.optional stdenv.targetPlatform.isDarwin "mac_deployment_target=\"${stdenv.targetPlatform.darwinMinVersion}\""
    );

    GN = lib.getExe gn;
    LIBCLANG_PATH = lib.makeLibraryPath [ llvmPackages.libclang ];
    NINJA = lib.getExe ninja;
    PYTHON = "python3";
    RUSTC_BOOTSTRAP = 1;
    V8_FROM_SOURCE = 1;
  };

  # Don't run checks on hydra as they've been observed to be flakey for us and
  # other distros CI: https://gitlab.alpinelinux.org/alpine/aports/-/blob/bec8b026686323b496365b825ad14fdf4473adf2/community/deno/APKBUILD#L79
  # We haven't reproduced it on local machines, could be related to doing other
  # builds simultaneously.
  # A build with tests is included as part of `deno.passhtru.tests` via `librusty_v8.passthru.tests`
  doCheck = false;

  # Check related config is left in the main package so if someone uses
  # `overrideAttrs` to always build with tests, it'll all work.
  checkFlags = [
    # These tests probably fail due to a more recent rustc version (upstream: 1.89.0, here: 1.93.0)
    "--skip=ui"
    "--skip=scope"
  ];

  installPhase = ''
    runHook preInstall

    cp target/*/release/gn_out/obj/librusty_v8${stdenv.hostPlatform.extensions.staticLibrary} $out

    runHook postInstall
  '';

  buildFeatures = [ "simdutf" ];

  hardeningDisable = [
    # rusty-v8 has its own default hardening flags, which are "extensive" for release builds as long as `use_custom_libcxx` stays true.
    # Avoids many warnings about redefined macros (on build failures) and uses the upstream flag.
    "libcxxhardeningfast"
    # from Arch Linux: this uses malloc_usable_size, which is incompatible with fortification level 3
    # https://gitlab.archlinux.org/archlinux/packaging/packages/deno/-/blob/cd9bdf9e67381da413142413646bd8648807510a/PKGBUILD#L49
    "fortify3"
  ];

  requiredSystemFeatures = [ "big-parallel" ];

  passthru = {
    tests = {
      build-with-unit-tests = deno.passthru.librusty_v8.overrideAttrs (fa: {
        doCheck = true;
      });
    };
  };

  meta = {
    description = "Rust bindings for the V8 JavaScript engine";
    homepage = "https://github.com/denoland/rusty_v8";
    license = lib.licenses.mit;
    maintainers = deno.meta.maintainers;
    platforms = deno.meta.platforms;
    maxSilent = 14400; # 4h, double the default of 7200s; sometimes needed for x86_64-darwin on hydra
  };
})
