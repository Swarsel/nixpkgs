{
  lib,
  stdenv,
  fetchFromGitHub,
  binaryen,
  fetchNpmDeps,
  lld,
  nodejs,
  npmHooks,
  runCommand,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "extism-js-core";
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "extism";
    repo = "js-pdk";
    tag = "v${finalAttrs.version}";
    hash = "sha256-CLyH0gDtw988cTcw4B86/kejfbYWMXEVG9Y6PKAZazE=";
  };

  # https://github.com/extism/js-pdk/pull/154
  postPatch = ''
    substituteInPlace Cargo.toml \
      --replace-fail '1.5.1' '${finalAttrs.version}'
  '';

  nativeBuildInputs = [
    binaryen
    lld
    nodejs
    npmHooks.npmConfigHook
    rustPlatform.bindgenHook
  ];

  cargoHash = "sha256-9lFX+Q4318ClVIRT4/uCesyNYwU9H2vV+fD3553M2Dc=";
  # io-extras v0.18.4 uses #![feature]
  env.RUSTC_BOOTSTRAP = 1;
  env.RUSTFLAGS = "-C linker=wasm-ld";

  # rquickjs-sys expects the dir structure from wasi-sdk
  # https://github.com/DelSkayn/rquickjs/blob/v0.11.0/sys/build.rs#L216-L230
  # TODO: revisit when https://github.com/DelSkayn/rquickjs/pull/648 is released and extism updated
  env.WASI_SDK = runCommand "wasi-sdk" { } ''
    mkdir -p $out/bin
    ln -s ${lib.getExe' stdenv.cc "wasm32-unknown-wasi-clang"} $out/bin/clang
    ln -s ${lib.getExe' stdenv.cc "wasm32-unknown-wasi-ar"} $out/bin/ar
    ln -s ${stdenv.cc}/nix-support $out/nix-support
    mkdir -p $out/share
    ln -s ${stdenv.cc.libc} $out/share/wasi-sysroot
  '';

  preBuild = ''
    pushd ${finalAttrs.npmRoot}
    npm run build
    popd
  '';

  # https://github.com/extism/js-pdk/blob/v1.6.0/Makefile#L25
  preFixup = ''
    wasm-opt --enable-reference-types --enable-bulk-memory --strip -O3 $out/bin/js_pdk_core.wasm -o $out/bin/js_pdk_core.wasm
  '';

  __structuredAttrs = true;
  cargoBuildFlags = [ "--package=js-pdk-core" ];

  npmDeps = fetchNpmDeps {
    inherit (finalAttrs) src;
    hash = "sha256-XrydnNXXhy/2sZXUGHuZvy+WF7dYIywrUAj8OHGlVRM=";
    name = "${finalAttrs.pname}-${finalAttrs.version}-npm-deps";
    sourceRoot = "${finalAttrs.src.name}/${finalAttrs.npmRoot}";
  };

  npmRoot = "crates/core/src/prelude";

  meta = {
    description = "Write Extism plugins in JavaScript & TypeScript (WASM core)";
    homepage = "https://github.com/extism/js-pdk";
    changelog = "https://github.com/extism/js-pdk/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.bsd3;

    maintainers = [
      lib.maintainers.diogotcorreia
      lib.maintainers.dotlambda
    ];

    platforms = lib.platforms.wasi;
    # Fails to build on darwin due to libiconv linking failure (ld: library not found for -liconv)
    # See https://github.com/NixOS/nixpkgs/pull/523442 for a (failed) attempt at fixing the issue
    broken = stdenv.buildPlatform.isDarwin;
  };
})
