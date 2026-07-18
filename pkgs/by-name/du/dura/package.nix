{
  lib,
  fetchFromGitHub,
  openssl,
  pkg-config,
  rustPlatform,
  zlib,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "dura";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "tkellogg";
    repo = "dura";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-xAcFk7z26l4BYYBEw+MvbG6g33MpPUvnpGvgmcqhpGM=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
    zlib
  ];

  cargoHash = "sha256-Xci9168KqJf+mhx3k0d+nH6Ov5tqNtB6nxiL9BwVYjU=";
  doCheck = false;

  cargoPatches = [
    ./Cargo.lock.patch
  ];

  meta = {
    description = "Background process that saves uncommitted changes on git";

    longDescription = ''
      Dura is a background process that watches your Git repositories and
      commits your uncommitted changes without impacting HEAD, the current
      branch, or the Git index (staged files). If you ever get into an
      "oh snap!" situation where you think you just lost days of work,
      checkout a "dura" branch and recover.
    '';

    homepage = "https://github.com/tkellogg/dura";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "dura";
  };
})
