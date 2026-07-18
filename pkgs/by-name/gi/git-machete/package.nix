{
  lib,
  fetchFromGitHub,
  git,
  installShellFiles,
  nix-update-script,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "git-machete";
  version = "3.44.1";

  src = fetchFromGitHub {
    owner = "virtuslab";
    repo = "git-machete";
    tag = "v${finalAttrs.version}";
    hash = "sha256-OqNfKqp3nOXij9dSvStmRyYIQOF91F+pA+9rSGPp7gQ=";
  };

  nativeBuildInputs = [ installShellFiles ];

  nativeCheckInputs = [
    git
  ]
  ++ (with python3.pkgs; [
    pytest-mock
    pytestCheckHook
  ]);

  postInstall = ''
    installShellCompletion --bash --name git-machete completion/git-machete.completion.bash
    installShellCompletion --zsh --name _git-machete completion/git-machete.completion.zsh
    installShellCompletion --fish completion/git-machete.fish
  '';

  build-system = with python3.pkgs; [ setuptools ];

  disabledTests = [
    # Requires fully functioning shells including zsh modules and bash
    # completion.
    "completion_e2e"
  ];

  postInstallCheck = ''
    test "$($out/bin/git-machete version)" = "git-machete version ${finalAttrs.version}"
  '';

  pyproject = true;

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Git repository organizer and rebase/merge workflow automation tool";
    homepage = "https://github.com/VirtusLab/git-machete";
    changelog = "https://github.com/VirtusLab/git-machete/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ blitz ];
    mainProgram = "git-machete";
  };
})
