{
  lib,
  fetchFromGitHub,
  codeium,
  gitUpdater,
  melpaBuild,
  replaceVars,
}:

melpaBuild {
  pname = "codeium";
  version = "1.6.13";

  src = fetchFromGitHub {
    owner = "Exafunction";
    repo = "codeium.el";
    rev = "1.6.13";
    hash = "sha256-CjT21GhryO8/iM0Uzm/s/I32WqVo4M3tSlHC06iEDXA=";
  };

  patches = [
    (replaceVars ./0000-set-codeium-command-executable.patch {
      codeium = lib.getExe' codeium "codeium_language_server";
    })
  ];

  passthru.updateScript = gitUpdater { };

  meta = {
    inherit (codeium.meta) platforms;
    description = "Free, ultrafast Copilot alternative for Emacs";
    homepage = "https://github.com/Exafunction/codeium.el";
    license = lib.licenses.mit;
    sourceProvenance = [ lib.sourceTypes.fromSource ];
    maintainers = [ ];
  };

}
