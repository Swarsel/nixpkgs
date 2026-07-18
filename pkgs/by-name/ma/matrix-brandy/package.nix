{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL,
  libx11,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "matrix-brandy";
  version = "1.23.6";

  src = fetchFromGitHub {
    owner = "stardot";
    repo = "MatrixBrandy";
    rev = "V${finalAttrs.version}";
    hash = "sha256-Cyr3nfX8JHf8udTMQKTHy4sNVkSRjtScye6yUffLXHI=";
  };

  patches = lib.optionals stdenv.hostPlatform.isDarwin [ ./no-lrt.patch ];

  buildInputs = [
    libx11
    SDL
  ];

  makeFlags = lib.optionals stdenv.hostPlatform.isDarwin [
    "CC=cc"
    "LD=clang"
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp brandy $out/bin
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Matrix Brandy BASIC VI for Linux, Windows, MacOSX";
    homepage = "https://brandy.matrixnetwork.co.uk/";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ fiq ];
    platforms = lib.platforms.unix;
    mainProgram = "brandy";
  };
})
