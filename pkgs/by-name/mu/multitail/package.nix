{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ncurses,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "multitail";
  version = "7.1.5";

  src = fetchFromGitHub {
    owner = "folkertvanheusden";
    repo = "multitail";
    rev = finalAttrs.version;
    hash = "sha256-c9NlQLgHngNBbADZ6/legWFaKHJAQR/LZIfh8bJoc4Y=";
  };

  nativeBuildInputs = [
    pkg-config
    cmake
  ];

  buildInputs = [ ncurses ];

  installPhase = ''
    runHook preInstall

    install -Dm755 multitail -t $out/bin/

    runHook postInstall
  '';

  hardeningDisable = [ "format" ];

  meta = {
    description = "tail on steroids";
    homepage = "https://github.com/folkertvanheusden/multitail";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ matthiasbeyer ];
    platforms = lib.platforms.unix;
    mainProgram = "multitail";
  };
})
