{
  stdenv,
  cargo,
  rustPlatform,
}:
{
  cargoBuildHook = stdenv.mkDerivation {
    src = ./example-rust-project;

    nativeBuildInputs = [
      rustPlatform.cargoBuildHook
      cargo
    ];

    installPhase = ''
      mkdir -p $out/bin
      mv target/${stdenv.hostPlatform.rust.cargoShortTarget}/release/hello $out/bin/
    '';

    "CARGO_TARGET_${stdenv.hostPlatform.rust.cargoEnvVarTarget}_LINKER" =
      "${stdenv.cc}/bin/${stdenv.cc.targetPrefix}cc";

    cargoBuildType = "release";
    name = "test-cargoBuildHook";
  };

  cargoCheckHook = stdenv.mkDerivation {
    src = ./example-rust-project;

    nativeBuildInputs = [
      rustPlatform.cargoCheckHook
      cargo
    ];

    buildPhase = ''
      cargo build --profile release --target ${stdenv.hostPlatform.rust.rustcTarget}
      runHook postBuild
    '';

    doCheck = true;

    installPhase = ''
      mkdir -p $out/bin
      mv target/${stdenv.hostPlatform.rust.cargoShortTarget}/release/hello $out/bin/
    '';

    "CARGO_TARGET_${stdenv.hostPlatform.rust.cargoEnvVarTarget}_LINKER" =
      "${stdenv.cc}/bin/${stdenv.cc.targetPrefix}cc";

    cargoBuildType = "release";
    cargoCheckType = "release";
    name = "test-cargoCheckHook";
  };

  cargoInstallHook = stdenv.mkDerivation {
    src = ./example-rust-project;

    nativeBuildInputs = [
      rustPlatform.cargoInstallHook
      cargo
    ];

    buildPhase = ''
      cargo build --profile release --target ${stdenv.hostPlatform.rust.rustcTarget}
      runHook postBuild
    '';

    "CARGO_TARGET_${stdenv.hostPlatform.rust.cargoEnvVarTarget}_LINKER" =
      "${stdenv.cc}/bin/${stdenv.cc.targetPrefix}cc";

    cargoBuildType = "release";
    name = "test-cargoInstallHook";
  };

  cargoNextestHook = stdenv.mkDerivation {
    src = ./example-rust-project;

    nativeBuildInputs = [
      rustPlatform.cargoNextestHook
      cargo
    ];

    buildPhase = ''
      cargo build --profile release --target ${stdenv.hostPlatform.rust.rustcTarget}
      runHook postBuild
    '';

    doCheck = true;

    installPhase = ''
      mkdir -p $out/bin
      mv target/${stdenv.hostPlatform.rust.cargoShortTarget}/release/hello $out/bin/
    '';

    "CARGO_TARGET_${stdenv.hostPlatform.rust.cargoEnvVarTarget}_LINKER" =
      "${stdenv.cc}/bin/${stdenv.cc.targetPrefix}cc";

    cargoBuildType = "release";
    cargoCheckType = "release";
    name = "test-cargoNextestHook";
  };

  /*
    test each hook individually, to make sure that:
      - each hook works properly outside of buildRustPackage
      - each hook is usable independently from each other
  */
  cargoSetupHook = stdenv.mkDerivation {
    src = ./example-rust-project;

    nativeBuildInputs = [
      rustPlatform.cargoSetupHook
      cargo
    ];

    buildPhase = ''
      cargo build --profile release --target ${stdenv.hostPlatform.rust.rustcTarget}
    '';

    installPhase = ''
      mkdir -p $out/bin
      mv target/${stdenv.hostPlatform.rust.cargoShortTarget}/release/hello $out/bin/
    '';

    cargoVendorDir = "hello";
    name = "test-cargoSetupHook";
  };
}
