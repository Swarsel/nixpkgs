{
  lib,
  fetchFromGitHub,
  installShellFiles,
  nix-update-script,
  revolver,
  stdenvNoCC,
  testers,
  zsh,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "zunit";
  version = "0.8.2";

  src = fetchFromGitHub {
    owner = "zunit-zsh";
    repo = "zunit";
    rev = "v${finalAttrs.version}";
    hash = "sha256-kXgJjD7N9pUIk57g/EEXZ8ADypuVO+Vyj8ssgwOzVCg=";
    # The "tests" folder is missing in GitHub-provided download archives.
    # work around with `git clone`.
    # https://github.com/orgs/community/discussions/180774
    forceFetchGit = true;
  };

  postPatch = ''
    for i in $(find src/ -type f -print); do
      substituteInPlace $i \
        --replace-warn " revolver " " ${lib.getExe revolver} "
    done
  '';

  strictDeps = true;

  nativeBuildInputs = [
    zsh
    installShellFiles
  ];

  buildInputs = [
    zsh
    revolver
  ];

  buildPhase = ''
    runHook preBuild

    zsh build.zsh

    runHook postBuild
  '';

  doCheck = true;
  nativeCheckInputs = [ revolver ];

  checkPhase = ''
    runHook preCheck

    HOME="$TEMPDIR" zsh zunit

    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 zunit $out/bin/zunit

    runHook postInstall
  '';

  postInstall = ''
    installShellCompletion --cmd zunit --zsh zunit.zsh-completion
  '';

  doInstallCheck = true;

  installCheckPhase = ''
    runHook preInstallCheck

    PATH=$PATH:$out/bin zunit --help

    runHook postInstallCheck
  '';

  passthru = {
    tests.version = testers.testVersion { package = finalAttrs.finalPackage; };
    updateScript = nix-update-script { };
  };

  meta = {
    inherit (zsh.meta) platforms;
    description = "Powerful testing framework for ZSH projects";
    homepage = "https://zunit.xyz/";
    changelog = "https://github.com/zunit-zsh/zunit/releases/tag/${finalAttrs.src.rev}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ d-brasher ];
    mainProgram = "zunit";
    downloadPage = "https://github.com/zunit-zsh/zunit/releases";
  };
})
