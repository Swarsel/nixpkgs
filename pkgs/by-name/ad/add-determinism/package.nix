{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  rustPlatform,
  zlib,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "add-determinism";
  version = "0.7.3";

  src = fetchFromGitHub {
    owner = "keszybz";
    repo = "add-determinism";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Gg1tObrUtHDjw52g3jjJm5bD5ctxujWOolaCqV7+ZjQ=";
  };

  postPatch = ''
    ln -s ${./Cargo.lock} Cargo.lock
  '';

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    zlib
  ];

  # this project has no Cargo.lock now
  cargoLock = {
    lockFile = ./Cargo.lock;
  };

  doCheck = !stdenv.hostPlatform.isDarwin; # it seems to be running forever on darwin

  postInstall = ''
    ln -s add-det $out/bin/add-determinism
  '';

  meta = {
    description = "Build postprocessor to reset metadata fields for build reproducibility";
    homepage = "https://github.com/keszybz/add-determinism";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      Emin017
      sharzy
    ];

    platforms = lib.platforms.all;
    mainProgram = "add-det";
  };
})
