{
  lib,
  fetchFromGitHub,
  imagemagick,
  nix-update-script,
  nototools,
  pngquant,
  stdenvNoCC,
  which,
  zopfli,
}:

stdenvNoCC.mkDerivation rec {
  pname = "whatsapp-emoji-linux";
  version = "2.26.8.72-1";

  src = fetchFromGitHub {
    owner = "dmlls";
    repo = "whatsapp-emoji-linux";
    tag = version;
    hash = "sha256-72qqW68kmAqm2+Z5ldWMHEJL8LXpE93A32VsmW+dbY8=";
  };

  nativeBuildInputs = [
    imagemagick
    nototools
    pngquant
    which
    zopfli
  ];

  makeFlags = [
    "PREFIX=$(out)"
  ];

  enableParallelBuilding = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "WhatsApp Emoji for GNU/Linux";
    homepage = "https://github.com/dmlls/whatsapp-emoji-linux";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
    maintainers = [ lib.maintainers.lucasew ];
  };
}
