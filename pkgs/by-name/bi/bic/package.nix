{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf-archive,
  autoreconfHook,
  bison,
  flex,
  gcc,
  gmp,
  libffi,
  makeWrapper,
  pkg-config,
  readline,
}:

stdenv.mkDerivation {
  pname = "bic";
  version = "1.0.0-unstable-2022-02-16";

  src = fetchFromGitHub {
    owner = "hexagonal-sun";
    repo = "bic";
    rev = "b224d2776fdfe84d02eb96a21880a9e4ceeb3065";
    hash = "sha256-6na7/kCXhHN7utbvXvTWr3QG4YhDww9AkilyKf71HlM=";
  };

  nativeBuildInputs = [
    autoreconfHook
    autoconf-archive
    bison
    flex
    gcc
    libffi
    makeWrapper
    pkg-config
  ];

  buildInputs = [
    readline
    gcc
    gmp
  ];

  postInstall = ''
    wrapProgram $out/bin/bic \
      --prefix PATH : ${lib.makeBinPath [ gcc ]}
  '';

  meta = {
    description = "C interpreter and API explorer";

    longDescription = ''
      bic This a project that allows developers to explore and test C-APIs using a
      read eval print loop, also known as a REPL.
    '';

    homepage = "https://github.com/hexagonal-sun/bic";
    license = with lib.licenses; [ gpl2Plus ];
    maintainers = with lib.maintainers; [ hexagonal-sun ];
    platforms = lib.platforms.unix;
    mainProgram = "bic";
    # never built on aarch64-darwin since first introduction in nixpkgs
    broken = stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64;
  };
}
