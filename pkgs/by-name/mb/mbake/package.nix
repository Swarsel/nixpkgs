{
  lib,
  stdenv,
  fetchFromGitHub,
  installShellFiles,
  python3Packages,
  versionCheckHook,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "mbake";
  version = "1.4.6";

  src = fetchFromGitHub {
    owner = "EbodShojaei";
    repo = "bake";
    tag = "v${finalAttrs.version}";
    hash = "sha256-pA72tKQ3ji2VlW+7rFGNW3yPZmBS9JHqVF0/gpUUqAk=";
  };

  nativeCheckInputs = [
    python3Packages.pytestCheckHook
    versionCheckHook
  ];

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd mbake \
      --bash <($out/bin/mbake completions bash) \
      --fish <($out/bin/mbake completions fish) \
      --zsh <($out/bin/mbake completions zsh)
  '';

  build-system = [
    installShellFiles
    python3Packages.hatchling
  ];

  dependencies = with python3Packages; [
    rich
    typer
  ];

  pyproject = true;
  pythonImportsCheck = [ "mbake" ];

  meta = {
    description = "Makefile formatter and linter";
    homepage = "https://github.com/EbodShojaei/bake";
    changelog = "https://github.com/EbodShojaei/bake/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.amadejkastelic ];
    mainProgram = "mbake";
  };
})
