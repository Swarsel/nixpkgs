{
  lib,
  stdenv,
  binaryen,
  buildPackages,
  cargo,
  fluffychat-web,
  flutter,
  flutter_rust_bridge_codegen,
  removeReferencesTo,
  runCommand,
  rustPlatform,
  rustc,
  symlinkJoin,
  wasm-bindgen-cli_0_2_100,
  wasm-pack,
  which,
  writableTmpDirAsHomeHook,
}:

let
  pubSources = fluffychat-web.pubspecLock.dependencySources;
  pubCache = runCommand "fluffychat-pub-cache" { } ''
    mkdir -p $out/hosted/pub.dev
    pushd $out/hosted/pub.dev
      ${lib.concatMapAttrsStringSep "; " (
        _: p:
        "ln -s ${p} ./${if lib.hasPrefix "pub-" p.name then lib.removePrefix "pub-" p.name else p.name}"
      ) pubSources}
    popd
  '';

  # wasm-pack doesn't take 'RUST_SRC_PATH' into consideration
  sysroot = symlinkJoin {
    postBuild = ''
      mkdir -p $out/lib/rustlib/src/rust
      ln -s ${rustPlatform.rustLibSrc} $out/lib/rustlib/src/rust/library
    '';

    name = "rustc_unwrapped_with_libsrc";

    paths = [
      buildPackages.rustc.unwrapped
    ];
  };
  rustcWithLibSrc = buildPackages.rustc.override { inherit sysroot; };
in

# https://github.com/krille-chan/fluffychat/blob/main/scripts/prepare-web.sh
stdenv.mkDerivation {
  inherit (pubSources.vodozemac) version;
  inherit (fluffychat-web) meta;
  pname = "vodozemac-wasm";

  # Remove dev_dependencies to avoid downloading them
  postPatch = ''
    sed -i '/^dev_dependencies:/,/^$/d' dart/pubspec.yaml
  '';

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    rustcWithLibSrc
    rustc.llvmPackages.lld
    cargo
    flutter
    flutter_rust_bridge_codegen
    which
    wasm-pack
    wasm-bindgen-cli_0_2_100
    binaryen
    writableTmpDirAsHomeHook
    removeReferencesTo
  ];

  env = {
    RUSTC_BOOTSTRAP = 1; # `-Z build-std=std,panic_abort` requires nightly toolchain
  };

  buildPhase = ''
    runHook preBuild

    export PUB_CACHE=$TMPDIR/pub-cache
    mkdir -p $PUB_CACHE/hosted
    ln -s ${pubCache}/hosted/pub.dev $PUB_CACHE/hosted/pub.dev

    pushd dart
      dart pub get --offline
    popd
    RUST_LOG=info flutter_rust_bridge_codegen build-web \
      --dart-root $(realpath ./dart) --rust-root $(realpath ./rust) --release

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r dart/web/pkg/vodozemac_bindings_dart* $out/

    runHook postInstall
  '';

  # fix rustc leaking into closure
  # fluffychat-web should not reference build-time dependencies
  preFixup = ''
    find $out -name "*.wasm" -exec remove-references-to -t ${sysroot} {} +
  '';

  cargoDeps = symlinkJoin {
    # Pull in rust vendor so we don't have to vendor rustLibSrc again
    # This is required because `-Z build-std=std,panic_abort` rebuilds std
    postBuild = ''
      cp -rsn ${rustPlatform.rustVendorSrc}/* $out/*/
    '';

    name = "vodozemac-wasm-cargodeps";
    paths = [ pubSources.flutter_vodozemac.passthru.cargoDeps ];
  };

  cargoRoot = "rust";

  # These two were in the same repository, so just reuse them
  unpackPhase = ''
    runHook preUnpack

    cp -r ${pubSources.flutter_vodozemac}/rust ./rust
    cp -r ${pubSources.vodozemac} ./dart
    chmod -R +rwx .

    runHook postUnpack
  '';
}
