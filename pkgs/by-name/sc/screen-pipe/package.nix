{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  dbus,
  ffmpeg,
  libxcb,
  oniguruma,
  openssl,
  pkg-config,
  rustPlatform,
  sqlite,
}:
rustPlatform.buildRustPackage rec {
  pname = "screen-pipe";
  version = "0.1.48";

  src = fetchFromGitHub {
    owner = "louis030195";
    repo = "screen-pipe";
    rev = "v${version}";
    hash = "sha256-rWKRCqWFuPO84C52mMrrS4euD6XdJU8kqZsAz28+vWE=";
  };

  postPatch = ''
    ln -s ${./Cargo.lock} Cargo.lock
  '';

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    dbus
    ffmpeg
    oniguruma
    openssl
    sqlite
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    alsa-lib
    libxcb
  ];

  cargoLock = {
    lockFile = ./Cargo.lock;

    outputHashes = {
      "cpal-0.15.3" = "sha256-eKn3tS5QuqbMTwnRAEybvbPZOiKiid7ghGztAmrs9fw=";
      "rusty-tesseract-1.1.10" = "sha256-XT74zGn+DetEBUujHm4Soe2iorQcIoUeZbscTv+64hw=";
    };
  };

  env = {
    RUSTONIG_SYSTEM_LIBONIG = true;
  };

  doCheck = false; # Tests fail to build
  buildFeatures = lib.optional stdenv.hostPlatform.isDarwin "metal";

  meta = {
    description = "Personalized AI powered by what you've seen, said, or heard";
    homepage = "https://github.com/louis030195/screen-pipe";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "screen-pipe";
    # Marked broken 2025-11-28 because it has failed on Hydra for at least one year.
    broken = true;
  };
}
