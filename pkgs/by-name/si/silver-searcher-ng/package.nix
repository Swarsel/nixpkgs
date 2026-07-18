{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  git,
  pcre2,
  pkg-config,
  python3Packages,
  xz,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "silver-searcher-ng";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "silver-searcher";
    repo = "silver-searcher-ng";
    rev = finalAttrs.version;
    hash = "sha256-IiVFbS9XGmqcGN4NRXFC07cV6bGKDs9C2y5XxJKdvFk=";
  };

  patches = [ ./bash-completion.patch ];
  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    pcre2
    zlib
    xz
  ];

  env = lib.optionalAttrs stdenv.hostPlatform.isLinux {
    NIX_LDFLAGS = "-lgcc_s";
  };

  doCheck = true;

  nativeCheckInputs = [
    python3Packages.cram
    git
  ];

  checkPhase = ''
    runHook preCheck

    make test

    runHook postCheck
  '';

  __structuredAttrs = true;

  meta = {
    description = "Code-searching tool similar to ack, but faster";
    homepage = "https://github.com/silver-searcher/silver-searcher-ng";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ timschumi ];
    platforms = lib.platforms.all;
    mainProgram = "ag";
  };
})
