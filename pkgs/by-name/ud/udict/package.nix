{
  lib,
  fetchFromGitHub,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "udict";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "lsmb";
    repo = "udict";
    rev = "v${finalAttrs.version}";
    hash = "sha256-vcyzMw2tWil4MULEkf25S6kXzqMG6JXIx6GibxxspkY=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  cargoHash = "sha256-KlWzcJtNBTLCDDH01vI1mn9H7LUqni5o/Q6PsNeI7HE=";

  cargoPatches = [
    ./0001-update-version-in-lock-file.patch
  ];

  meta = {
    description = "Urban Dictionary CLI - written in Rust";
    homepage = "https://github.com/lsmb/udict";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "udict";
  };
})
