{
  lib,
  fetchFromGitHub,
  gitUpdater,
  installShellFiles,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "gradle-completion";
  version = "9.6.1";

  src = fetchFromGitHub {
    owner = "gradle";
    repo = "gradle-completion";
    tag = "v${finalAttrs.version}";
    hash = "sha256-bazehfRFvrcKOd5ZCUeKl/Ru/NtlVVS8LoZio+kI7+8=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    installShellFiles
  ];

  installPhase = ''
    runHook preInstall

    installShellCompletion --name gradle \
      --bash gradle-completion.bash \
      --zsh _gradle

    runHook postInstall
  '';

  dontBuild = true;
  # we just move two files into $out,
  # this shouldn't bother Hydra.
  preferLocalBuild = true;

  passthru.updateScript = gitUpdater {
    rev-prefix = "v";
  };

  meta = {
    description = "Gradle tab completion for bash and zsh";
    homepage = "https://github.com/gradle/gradle-completion";
    changelog = "https://github.com/gradle/gradle-completion/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    teams = [ lib.teams.java ];
  };
})
