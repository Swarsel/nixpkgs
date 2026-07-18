{
  stdenv,
  fetchFromGitHub,
  SDL2,
  SDL2_net,
  fetchzip,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "opentyrian";
  version = "2.1.20221123";

  src = fetchFromGitHub {
    owner = "opentyrian";
    repo = "opentyrian";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-fVcc8v1c9uU72X6afEo4VoMo6YuDECQSwDQ/TQjgwUY=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    SDL2
    SDL2_net
  ];

  makeFlags = [ "prefix=${placeholder "out"}" ];

  postInstall = ''
    mkdir -p $out/share/games/tyrian
    cp -r $data/* $out/share/games/tyrian/
  '';

  data = fetchzip {
    sha256 = "1biz6hf6s7qrwn8ky0g6p8w7yg715w7yklpn6258bkks1s15hpdb";
    url = "https://camanis.net/tyrian/tyrian21.zip";
  };

  enableParallelBuilding = true;

  meta = {
    description = ''Open source port of the game "Tyrian"'';
    homepage = "https://github.com/opentyrian/opentyrian";
    mainProgram = "opentyrian";
    # This does not account of Tyrian data.
    # license = lib.licenses.gpl2;
  };
})
