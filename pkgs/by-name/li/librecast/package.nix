{
  lib,
  stdenv,
  fetchFromCodeberg,
  lcrq,
  libsodium,
  nix-update-script,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "librecast";
  version = "0.11.2";

  src = fetchFromCodeberg {
    owner = "librecast";
    repo = "librecast";
    tag = "v${finalAttrs.version}";
    hash = "sha256-FFumVHTobvcty3x26IAMHP8M3fYrnfLtxt/RJ/4vKBg=";
  };

  buildInputs = [
    lcrq
    libsodium
  ];

  installFlags = [ "PREFIX=$(out)" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "IPv6 multicast library";
    homepage = "https://librecast.net/librecast.html";
    changelog = "https://codeberg.org/librecast/librecast/src/tag/v${finalAttrs.version}/CHANGELOG.md";

    license = with lib.licenses; [
      gpl2Only
      gpl3Only
    ];

    maintainers = with lib.maintainers; [
      albertchae
      aynish
      DMills27
      jasonodoom
      jleightcap
    ];

    platforms = lib.platforms.gnu;
    teams = with lib.teams; [ ngi ];
  };
})
