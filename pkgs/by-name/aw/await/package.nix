{
  lib,
  stdenv,
  fetchFromGitHub,
  installShellFiles,
  versionCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "await";
  version = "2.7.0";

  src = fetchFromGitHub {
    owner = "slavaGanzin";
    repo = "await";
    tag = finalAttrs.version;
    hash = "sha256-dtFwlGFjuaUdbggcFviLTnv2zBY6ktK8BASiz4XUeoE=";
  };

  nativeBuildInputs = [ installShellFiles ];

  buildPhase = ''
    runHook preBuild
    $CC await.c -o await -l pthread
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 await -t $out/bin
    install -Dm444 LICENSE -t $out/share/licenses/await
    install -Dm444 README.md -t $out/share/doc/await
    installShellCompletion --cmd await autocompletions/await.{bash,fish,zsh}

    runHook postInstall
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  meta = {
    description = "Small binary that runs a list of commands in parallel and awaits termination";
    homepage = "https://github.com/slavaGanzin/await";
    changelog = "https://github.com/slavaGanzin/await/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.all;
    mainProgram = "await";
  };
})
