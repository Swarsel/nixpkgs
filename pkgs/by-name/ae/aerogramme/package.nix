{
  lib,
  fetchgit,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "aerogramme";
  version = "0.3.0";

  src = fetchgit {
    url = "https://git.deuxfleurs.fr/Deuxfleurs/aerogramme/";
    tag = finalAttrs.version;
    hash = "sha256-ER+P/XGqNzTLwDLK5EBZq/Dl29ZZKl2FdxDb+oLEJ8Y=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];
  cargoHash = "sha256-GPj8qhfKgfAadQD9DJafN4ec8L6oY62PS/w/ljkPHpw=";

  env = {
    # get openssl-sys to use pkg-config
    OPENSSL_NO_VENDOR = true;
    RUSTC_BOOTSTRAP = true;
  };

  # disable network tests as Nix sandbox breaks them
  doCheck = false;

  cargoPatches = [
    ./0001-update-time-rs.patch
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Encrypted e-mail storage over Garage";
    homepage = "https://aerogramme.deuxfleurs.fr/";
    license = lib.licenses.eupl12;
    maintainers = with lib.maintainers; [ supinie ];
    platforms = lib.platforms.linux;
    mainProgram = "aerogramme";
    teams = with lib.teams; [ ngi ];
  };
})
