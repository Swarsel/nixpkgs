{
  libdeltachat,
  pkg-config,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage {
  inherit (libdeltachat)
    version
    src
    cargoDeps
    buildInputs
    ;

  pname = "deltachat-rpc-server";

  nativeBuildInputs = [
    pkg-config
  ];

  env = {
    OPENSSL_NO_VENDOR = true;
  };

  doCheck = false;
  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  cargoBuildFlags = [
    "--package"
    "deltachat-rpc-server"
  ];

  meta = libdeltachat.meta // {
    description = "Delta Chat RPC server exposing JSON-RPC core API over standard I/O";
    mainProgram = "deltachat-rpc-server";
  };
}
