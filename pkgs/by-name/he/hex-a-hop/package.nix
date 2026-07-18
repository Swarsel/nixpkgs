{
  lib,
  stdenv,
  fetchurl,
  SDL,
  SDL_mixer,
  SDL_ttf,
  fetchzip,
}:

stdenv.mkDerivation rec {
  pname = "hex-a-hop";
  version = "1.1.0";

  src = fetchzip {
    url = "mirror://sourceforge/project/hexahop/${version}/hex-a-hop-${version}.tar.gz";
    sha256 = "sha256-fBSvNtgNR0aNofbvoYpM1e8ww4ARlXIvrQUvJqVGLlY=";
  };

  buildInputs = [
    SDL
    SDL_mixer
    SDL_ttf
  ];

  makeFlags = [ "PREFIX=$(out)" ];

  postFixup = ''
    install -Dm644 ${icon} $out/share/icons/${pname}.png
    install -Dm644 ${desktop} $out/share/applications/${pname}.desktop
  '';

  desktop = fetchurl {
    sha256 = "sha256-j6gKRq+8b1NDwP1WcCaScfmwNxAl78CfK6pemROrRak=";
    # Fetched from e67385078e4f248a3877ee1066613d231c0d0eee, remove in the next version when the file is included
    url = "https://sourceforge.net/p/hexahop/code/ci/e67385078e4f248a3877ee1066613d231c0d0eee/tree/data/hex-a-hop.desktop?format=raw";
  };

  icon = fetchurl {
    sha256 = "sha256-Vh/1wwRmC2eSD/+mk1Oqt7EX4a4k++nUAbWQD2P2hNA=";
    # Fetched from dfa365a90be5c52ef21235a9e90a865b04da3ad4, remove in the next version when the file is included
    url = "https://sourceforge.net/p/hexahop/code/ci/dfa365a90be5c52ef21235a9e90a865b04da3ad4/tree/data/hex-a-hop.png?format=raw";
  };

  meta = {
    description = "Puzzle game based on hexagonal tiles";
    homepage = "https://hexahop.sourceforge.net";

    license = with lib.licenses; [
      gpl2Plus # Main code
      cc-by-30 # Assets
      lgpl2Plus # i18n
      lgpl3Plus # source files from Lips of Suna
    ];

    maintainers = with lib.maintainers; [ rampoina ];
    platforms = lib.platforms.linux;
    mainProgram = "hex-a-hop";
  };
}
