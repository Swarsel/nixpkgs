{
  lib,
  clang,
  fetchCrate,
  rustPlatform,
  rustfmt,
}:
let
  # bindgen hardcodes rustfmt outputs that use nightly features
  rustfmt-nightly = rustfmt.override { asNightly = true; };
in
rustPlatform.buildRustPackage rec {
  pname = "rust-bindgen-unwrapped";
  version = "0.72.1";

  src = fetchCrate {
    inherit version;
    hash = "sha256-rhdQZcnlqVSUqvFDg0Scs1+DHGcKyazeS5H9HH7u8Fk=";
    pname = "bindgen-cli";
  };

  cargoHash = "sha256-YNpqVB+zdZ76Av2L+yQuBrxKvNML9+3H7ES4+7mED0E=";
  env.RUSTFMT = "${rustfmt-nightly}/bin/rustfmt";

  preConfigure = ''
    export LIBCLANG_PATH="${lib.getLib clang.cc}/lib"
  '';

  doCheck = true;
  nativeCheckInputs = [ clang ];

  preCheck = ''
    # for the ci folder, notably
    patchShebangs .
  '';

  buildFeatures = [ "logging" ];
  # Disable the "runtime" feature, so libclang is linked.
  buildNoDefaultFeatures = true;
  checkFeatures = buildFeatures;
  checkNoDefaultFeatures = buildNoDefaultFeatures;
  passthru = { inherit clang; };

  meta = {
    description = "Automatically generates Rust FFI bindings to C (and some C++) libraries";

    longDescription = ''
      Bindgen takes a c or c++ header file and turns them into
      rust ffi declarations.
    '';

    homepage = "https://github.com/rust-lang/rust-bindgen";
    license = with lib.licenses; [ bsd3 ];
    maintainers = with lib.maintainers; [ johntitor ];
    platforms = lib.platforms.unix;
    mainProgram = "bindgen";
  };
}
