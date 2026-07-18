{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  gitpython,
  # nativeBuildInputs
  installShellFiles,
  pydantic-settings,
  # build-system
  setuptools,
  typer,
}:

buildPythonPackage (finalAttrs: {
  pname = "git-dummy";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "initialcommit-com";
    repo = "git-dummy";
    tag = "v${finalAttrs.version}";
    hash = "sha256-viybxn2J7SO7NgSvjwlP+tgtm+H6QrACafIy82d9XEk=";
  };

  nativeBuildInputs = [ installShellFiles ];

  postInstall =
    # https://github.com/NixOS/nixpkgs/issues/308283
    lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
      installShellCompletion --cmd git-dummy \
        --bash <($out/bin/git-dummy --show-completion bash) \
        --fish <($out/bin/git-dummy --show-completion fish) \
        --zsh <($out/bin/git-dummy --show-completion zsh)
    '';

  build-system = [ setuptools ];

  dependencies = [
    gitpython
    pydantic-settings
    typer
  ];

  pyproject = true;

  meta = {
    description = "Generate dummy Git repositories populated with the desired number of commits, branches, and structure";
    homepage = "https://github.com/initialcommit-com/git-dummy";
    changelog = "https://github.com/initialcommit-com/git-dummy/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ mathiassven ];
    mainProgram = "git-dummy";
  };
})
