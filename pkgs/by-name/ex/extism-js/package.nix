{
  lib,
  binaryen,
  extism-cli,
  pkg-config,
  pkgsCross,
  rustPlatform,
  testers,
  versionCheckHook,
  writableTmpDirAsHomeHook,
  zstd,
}:

let
  inherit (pkgsCross.wasi32) extism-js-core;
in
rustPlatform.buildRustPackage (finalAttrs: {
  inherit (extism-js-core)
    version
    src
    cargoDeps
    postPatch
    ;

  pname = "extism-js";

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    zstd
  ];

  env.EXTISM_ENGINE_PATH = "${pkgsCross.wasi32.extism-js-core}/bin/js_pdk_core.wasm";
  # fs-set-times v0.20.3 uses #![feature]
  env.RUSTC_BOOTSTRAP = 1;
  env.ZSTD_SYS_USE_PKG_CONFIG = true;
  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  __structuredAttrs = true;
  cargoBuildFlags = [ "--package=js-pdk-cli" ];
  cargoTestFlags = [ "--package=js-pdk-cli" ];

  passthru = {
    tests.simple-js = testers.runCommand {
      nativeBuildInputs = [
        finalAttrs.finalPackage

        binaryen
        extism-cli
        writableTmpDirAsHomeHook
      ];

      # Based on https://github.com/extism/js-pdk/tree/v1.6.0/examples/simple_js
      name = "${finalAttrs.pname}-simple-js-test";

      script = ''
        cat <<'EOF' > script.js
        function helloWorld() {
          Host.outputString(`Hello, ''${Host.inputString()}!`);
        }

        module.exports = { helloWorld };
        EOF

        cat <<EOF > script.d.ts
        declare module "main" {
          export function helloWorld(): I32;
        }
        EOF

        cat <<EOF > expected
        Hello, nixpkgs!
        EOF

        extism-js script.js -i script.d.ts -o script.wasm
        extism call script.wasm helloWorld --wasi --input="nixpkgs" > output

        diff output expected && touch $out
      '';
    };
  };

  meta = {
    inherit (extism-js-core.meta) homepage license maintainers;
    description = "Write Extism plugins in JavaScript & TypeScript (CLI)";
    changelog = "https://github.com/extism/js-pdk/releases/tag/${finalAttrs.src.tag}";
    platforms = lib.platforms.unix;
    mainProgram = "extism-js";
  };
})
