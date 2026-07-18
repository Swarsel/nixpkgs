{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchYarnDeps,
  nodejs,
  testers,
  yarnConfigHook,
  yarnInstallHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "codefresh";
  version = "1.0.6";

  src = fetchFromGitHub {
    owner = "codefresh-io";
    repo = "cli";
    rev = "v${finalAttrs.version}";
    hash = "sha256-8jSLZ9aWgQmQ0DYqKVaTi9JNQVbG7htLoLzkew8TLwo=";
  };

  nativeBuildInputs = [
    yarnConfigHook
    yarnInstallHook
    nodejs
  ];

  offlineCache = fetchYarnDeps {
    hash = "sha256-FZd/dSvb69YU41djXdGg7KI5ocgYfpOHXOjfKAg36/w=";
    yarnLock = "${finalAttrs.src}/yarn.lock";
  };

  passthru.tests.version = testers.testVersion {
    # codefresh needs to read a config file, this is faked out with a subshell
    command = "codefresh --cfconfig <(echo 'contexts:') version";
    package = finalAttrs.finalPackage;
  };

  meta = {
    description = "CLI tool to interact with Codefresh services";
    homepage = "https://github.com/codefresh-io/cli";
    changelog = "https://github.com/codefresh-io/cli/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = [
      lib.maintainers.burdzwastaken
      lib.maintainers.takac
    ];

    mainProgram = "codefresh";
  };
})
