{
  libdeltachat,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage {
  inherit (libdeltachat)
    version
    src
    cargoDeps
    buildInputs
    ;

  pname = "deltachat-repl";

  nativeBuildInputs = [
    pkg-config
  ];

  env = {
    OPENSSL_NO_VENDOR = true;
  };

  doCheck = false;

  cargoBuildFlags = [
    "--package"
    "deltachat-repl"
  ];

  meta = libdeltachat.meta // {
    description = "Delta Chat CLI client";
    mainProgram = "deltachat-repl";
  };
}
