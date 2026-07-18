{
  lib,
  stdenv,
  fetchFromGitHub,
  _experimental-update-script-combinators,
  makeWrapper,
  nix,
  serve,
  unstableGitUpdater,
  writeShellApplication,
  xsel,
  yarn-berry_4,
}:
let
  yarn-berry = yarn-berry_4;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "dokieli";
  version = "0-unstable-2026-05-08";

  src = fetchFromGitHub {
    owner = "dokieli";
    repo = "dokieli";
    rev = "f0372663098582c0310c9e16918a55cf000fbaf1";
    hash = "sha256-jpIQcE1GdjvEsk6HPxjdFLbrxGWvVCaaG7T08HdMj7Y=";
  };

  nativeBuildInputs = [
    makeWrapper
    yarn-berry
    yarn-berry.yarnBerryConfigHook
  ];

  buildPhase = ''
    runHook preBuild

    yarn build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp -r * $out

    runHook postInstall
  '';

  postFixup = ''
    makeWrapper ${lib.getExe serve} $out/bin/dokieli \
      --prefix PATH : ${lib.makeBinPath [ xsel ]} \
      --chdir $out
  '';

  missingHashes = ./missing-hashes.json;

  offlineCache = yarn-berry.fetchYarnBerryDeps {
    inherit (finalAttrs) src missingHashes;
    hash = "sha256-SEoYmh7oHmJrVhShOjRyaClyQxW9S96GCI3ggRkW+6U=";
  };

  passthru = {
    updateScript = _experimental-update-script-combinators.sequence [
      finalAttrs.passthru.updateScriptSrc
      (lib.getExe finalAttrs.passthru.updateScriptDeps)
    ];

    updateScriptDeps = writeShellApplication {
      name = "update-dokieli-berry-deps";

      runtimeInputs = [
        nix
        yarn-berry.yarn-berry-fetcher
      ];

      text = lib.strings.readFile ./updateDeps.sh;
    };

    updateScriptSrc = unstableGitUpdater { };
  };

  meta = {
    description = "Clientside editor for decentralised article publishing, annotations and social interactions";
    homepage = "https://github.com/linkeddata/dokieli";

    license = with lib.licenses; [
      cc-by-40
      mit
    ];

    maintainers = with lib.maintainers; [ shogo ];
    platforms = lib.platforms.all;
    mainProgram = "dokieli";
    teams = [ lib.teams.ngi ];
  };
})
