{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "yapesdl";
  version = "0.81.1";

  src = fetchFromGitHub {
    owner = "calmopyrin";
    repo = "yapesdl";
    rev = "v${finalAttrs.version}";
    hash = "sha256-vCScQmkODKZKbvrauuR9WNTjjKEvlomfzB0QifHxSVs=";
  };

  outputs = [
    "out"
    "doc"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    SDL2
    pkg-config
  ];

  buildInputs = [
    SDL2
  ];

  makeFlags = [ "CC=${stdenv.cc.targetPrefix}c++" ];

  installPhase = ''
    runHook preInstall
    install -Dm755 yapesdl -t ''${!outputBin}/bin/
    install -Dm755 README.SDL -t ''${!outputDoc}/share/doc/yapesdl/
    runHook postInstall
  '';

  meta = {
    description = "Multiplatform Commodore 64 and 264 family emulator";
    homepage = "http://yape.plus4.net/";
    changelog = "https://github.com/calmopyrin/yapesdl/releases/tag/${finalAttrs.src.rev}";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "yapesdl";
    broken = stdenv.hostPlatform.isDarwin;
  };
})
