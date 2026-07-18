{
  lib,
  stdenv,
  fetchFromCodeberg,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "lcrq";
  version = "0.3.1";

  src = fetchFromCodeberg {
    owner = "librecast";
    repo = "lcrq";
    rev = "v${finalAttrs.version}";
    hash = "sha256-hNH5SdvKhNPUJWs7vpPECcBsRyNdHQF+Ot3LmyX2V3c=";
  };

  installFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "Librecast RaptorQ library";
    homepage = "https://librecast.net/lcrq.html";
    changelog = "https://codeberg.org/librecast/lcrq/src/tag/v${finalAttrs.version}/CHANGELOG.md";

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

    platforms = lib.platforms.unix;
  };
})
