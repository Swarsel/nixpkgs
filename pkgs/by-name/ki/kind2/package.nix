{
  lib,
  fetchCrate,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "kind2";
  version = "0.3.10";

  src = fetchCrate {
    inherit (finalAttrs) pname version;
    hash = "sha256-X2sjfYrSSym289jDJV3hNmcwyQCMnrabmGCUKD5wfdY=";
  };

  postPatch = ''
    substituteInPlace src/main.rs \
      --replace-fail "#![feature(panic_info_message)]" ""
    substituteInPlace src/main.rs \
      --replace-fail "e.message().unwrap()" "e.payload()"
  '';

  cargoHash = "sha256-G6UW8m/6D+hgRRceMPYFI+k4D7Ui6sDUDzI5IVWvVyc=";
  # requires nightly features
  env.RUSTC_BOOTSTRAP = true;

  meta = {
    description = "Functional programming language and proof assistant";
    homepage = "https://github.com/higherorderco/kind";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "kind2";
  };
})
