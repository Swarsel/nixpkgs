{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  cmake,
  faad2,
  gtkmm3,
  mpg123,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dablin";
  version = "1.16.1";

  src = fetchFromGitHub {
    owner = "Opendigitalradio";
    repo = "dablin";
    rev = finalAttrs.version;
    sha256 = "sha256-dx+KPPFCx78HtNvEb00URX/eu49Wtj7fksPjDtpkk5Q=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    faad2
    mpg123
    SDL2
    gtkmm3
  ];

  meta = {
    description = "Play DAB/DAB+ from ETI-NI aligned stream";
    homepage = "https://github.com/Opendigitalradio/dablin";

    license = with lib.licenses; [
      gpl3Plus
      lgpl21Only
    ];

    maintainers = [ lib.maintainers.markuskowa ];
    platforms = lib.platforms.linux;
  };
})
