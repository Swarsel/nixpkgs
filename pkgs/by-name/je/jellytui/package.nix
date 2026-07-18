{
  lib,
  fetchFromGitHub,
  makeWrapper,
  mpv,
  openssl,
  pkg-config,
  rustPlatform,
}:
rustPlatform.buildRustPackage {
  pname = "jellytui";
  version = "0.1.5";

  src = fetchFromGitHub {
    owner = "tyrantlink";
    repo = "jellytui";
    rev = "7b10490261672d750af2e3483b88f7daf017afb6";
    hash = "sha256-cMSZDSN2qnTeKL3ZcNVRtS45Xa1kEcps9WpWuWruX/0=";
  };

  postPatch = ''
    ln -s ${./Cargo.lock} Cargo.lock
  '';

  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ];

  buildInputs = [
    openssl
    mpv
  ];

  cargoLock = {
    lockFile = ./Cargo.lock;
  };

  postInstall = ''
    wrapProgram $out/bin/jellytui \
      --prefix PATH : ${lib.makeBinPath [ mpv ]}
  '';

  meta = {
    description = "TUI client for Jellyfin, using mpv";
    homepage = "https://github.com/tyrantlink/jellytui";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ yanek ];
    mainProgram = "jellytui";
  };
}
