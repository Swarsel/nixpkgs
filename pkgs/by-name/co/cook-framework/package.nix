{
  lib,
  fetchFromGitHub,
  buildGoModule,
  gitUpdater,
}:

buildGoModule (finalAttrs: {
  pname = "cook-framework";
  version = "2.2.1";

  src = fetchFromGitHub {
    owner = "glitchedgitz";
    repo = "cook";
    tag = "v${finalAttrs.version}";
    hash = "sha256-DK0kbvM11t64nGkrzThZgSruHTCHAPP374YPWmoM50g=";
  };

  vendorHash = "sha256-VpNr06IiVKpMsJXzcKCuNfJ+T+zeA9dMBMp6jeCRgn8=";
  doCheck = false; # uses network to fetch data sources
  sourceRoot = "${finalAttrs.src.name}/v2";
  passthru.updateScript = gitUpdater { rev-prefix = "v"; };

  meta = {
    description = "Wordlist generator, splitter, merger, finder, saver for security researchers, bug bounty and hackers";
    homepage = "https://github.com/glitchedgitz/cook";
    changelog = "https://github.com/glitchedgitz/cook/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ tomasajt ];
    mainProgram = "cook";
  };
})
