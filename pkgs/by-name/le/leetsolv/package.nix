{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  versionCheckHook,
  writableTmpDirAsHomeHook,
}:

buildGoModule (finalAttrs: {
  pname = "leetsolv";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "eannchen";
    repo = "leetsolv";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ZZ5TtrVUVWUTrGkp4p5k/aNT/XfCwJPsTjTUMcSz7sc=";
  };

  vendorHash = null;
  # needed for unit tests, also for version test
  nativeCheckInputs = [ writableTmpDirAsHomeHook ];
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;

  ldflags = [
    "-s"
    "-X main.Version=${finalAttrs.version}"
    "-X main.BuildTime=1970-01-01T00:00:00Z"
    "-X main.GitCommit=${finalAttrs.src.rev}"
  ];

  versionCheckKeepEnvironment = [ "HOME" ];
  versionCheckProgramArg = "version";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Spaced repetition CLI for DSA and LeetCode";
    homepage = "https://github.com/eannchen/leetsolv";
    changelog = "https://github.com/eannchen/leetsolv/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ethancedwards8 ];
    mainProgram = "leetsolv";
  };
})
