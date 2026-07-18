{
  lib,
  stdenv,
  bison,
  fetchFromCodeberg,
  flex,
  lcrq,
  librecast,
  libsodium,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "lcagent";
  version = "0.1.0";

  src = fetchFromCodeberg {
    owner = "librecast";
    repo = "lcagent";
    tag = finalAttrs.version;
    hash = "sha256-Kr3VQ56V+Neo4CrKX5AasuftXNNJCx4NnsPz1UBBCog=";
  };

  nativeBuildInputs = [
    bison
    flex
  ];

  buildInputs = [
    lcrq
    librecast
    libsodium
  ];

  doCheck = true;
  installFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "Librecast multicast agent";
    homepage = "https://librecast.net/lcagent.html";
    changelog = "https://codeberg.org/librecast/lcagent/src/tag/v${finalAttrs.version}/CHANGELOG.md";

    license = [
      lib.licenses.gpl2Only
      lib.licenses.gpl3Only
    ];

    maintainers = with lib.maintainers; [
      jleightcap
      jasonodoom
    ];

    platforms = lib.platforms.gnu;
    mainProgram = "lcagent";
  };
})
