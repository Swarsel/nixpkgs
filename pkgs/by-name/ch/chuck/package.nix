{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  bison,
  darwin,
  flex,
  libjack2,
  libpulseaudio,
  libsndfile,
  nix-update-script,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "chuck";
  version = "1.5.5.8";

  src = fetchFromGitHub {
    owner = "ccrma";
    repo = "chuck";
    tag = "chuck-${finalAttrs.version}";
    hash = "sha256-GBgb7Bnq5R9Gs/chstjxO8qf+MfSXVftwCbgNW5qC5Y=";
  };

  nativeBuildInputs = [
    bison
    flex
    pkg-config
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    darwin.DarwinTools
  ];

  buildInputs = [
    libsndfile
  ]
  ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [
    alsa-lib
    libpulseaudio
    libjack2
  ];

  makeFlags = [
    "-C src"
    "DESTDIR=$(out)/bin"
    # fix hardcoded gcc
    "CC=cc"
    "CXX=c++"
  ];

  buildFlags = [ (if stdenv.hostPlatform.isDarwin then "mac" else "linux-all") ];
  passthru.updateScript = nix-update-script { extraArgs = [ "--version-regex=chuck-(.*)" ]; };

  meta = {
    description = "Programming language for real-time sound synthesis and music creation";
    homepage = "http://chuck.cs.princeton.edu";

    license = with lib.licenses; [
      gpl2Plus
      # or
      mit
    ];

    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "chuck";
  };
})
