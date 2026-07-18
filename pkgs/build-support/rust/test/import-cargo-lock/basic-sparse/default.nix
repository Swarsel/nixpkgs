{ rustPlatform }:

rustPlatform.buildRustPackage {
  pname = "basic-sparse";
  version = "0.1.0";
  src = ./package;

  cargoLock = {
    extraRegistries = {
      "sparse+https://index.crates.io/" = "https://static.crates.io/crates";
    };

    lockFile = ./package/Cargo.lock;
  };

  postConfigure = ''
    cargo metadata --offline
  '';

  doInstallCheck = true;

  installCheckPhase = ''
    $out/bin/basic-sparse
  '';
}
