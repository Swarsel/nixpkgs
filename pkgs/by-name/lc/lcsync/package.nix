{
  lib,
  stdenv,
  fetchFromCodeberg,
  lcrq,
  librecast,
  libsodium,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "lcsync";
  version = "0.3.2";

  src = fetchFromCodeberg {
    owner = "librecast";
    repo = "lcsync";
    rev = "v${finalAttrs.version}";
    hash = "sha256-KirMifJ5Mc3WXuIZjFv6ZIzpz/bjGHMU2jnRGGQ2w/I=";
  };

  buildInputs = [
    lcrq
    librecast
    libsodium
  ];

  configureFlags = [ "SETCAP_PROGRAM=true" ];
  doCheck = true;
  installFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "Librecast File and Syncing Tool";
    homepage = "https://librecast.net/lcsync.html";
    changelog = "https://codeberg.org/librecast/lcsync/src/tag/v${finalAttrs.version}/CHANGELOG.md";

    license = [
      lib.licenses.gpl2
      lib.licenses.gpl3
    ];

    maintainers = with lib.maintainers; [
      albertchae
      aynish
      DMills27
      jasonodoom
      jleightcap
    ];

    platforms = lib.platforms.gnu;
    mainProgram = "lcsync";
  };
})
