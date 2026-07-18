{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchYarnDeps,
  git,
  nix-update-script,
  nodejs,
  npmHooks,
  yarnConfigHook,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "auto-changelog";
  version = "2.5.0";

  src = fetchFromGitHub {
    owner = "cookpete";
    repo = "auto-changelog";
    rev = "v${finalAttrs.version}";
    hash = "sha256-ticQpDOQieLaWXfavDKIH0jSenRimp5QYeJy42BjpKw=";
  };

  nativeBuildInputs = [
    yarnConfigHook
    npmHooks.npmInstallHook
    nodejs
  ];

  doCheck = true;
  nativeCheckInputs = [ git ];

  checkPhase = ''
    runHook preCheck
    yarn --offline run test -i -g 'compileTemplate'
    runHook postCheck
  '';

  yarnOfflineCache = fetchYarnDeps {
    hash = "sha256-NGQbzogQi0XbeGd7fYNyw0i9Yo9j91CfeTdO7nhq4Yw=";
    yarnLock = "${finalAttrs.src}/yarn.lock";
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Command line tool for generating a changelog from git tags and commit history";
    homepage = "https://github.com/cookpete/auto-changelog";
    changelog = "https://github.com/cookpete/auto-changelog/blob/master/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "auto-changelog";
  };
})
