{
  lib,
  stdenv,
  fetchFromGitHub,
  installShellFiles,
  python3Packages,
  versionCheckHook,
}:

python3Packages.buildPythonApplication rec {
  pname = "pytr";
  version = "0.4.9";

  src = fetchFromGitHub {
    owner = "pytr-org";
    repo = "pytr";
    tag = "v${version}";
    hash = "sha256-W6OtXK9c8NV8wIhvaym2tAg6UNJtCEPk1mt5VB0+Rkg=";
  };

  nativeBuildInputs = [ installShellFiles ];

  nativeCheckInputs = [
    versionCheckHook
    python3Packages.pytestCheckHook
  ];

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd pytr \
      --bash <($out/bin/pytr completion bash) \
      --zsh <($out/bin/pytr completion zsh)
  '';

  build-system = with python3Packages; [
    hatchling
    hatch-babel
  ];

  dependencies = with python3Packages; [
    babel
    certifi
    coloredlogs
    cryptography
    curl-cffi
    packaging
    pathvalidate
    playwright
    pygments
    requests-futures
    shtab
    websockets
  ];

  pyproject = true;
  pythonImportsCheck = [ "pytr" ];

  meta = {
    description = "Use TradeRepublic in terminal and mass download all documents";
    homepage = "https://github.com/pytr-org/pytr";
    changelog = "https://github.com/pytr-org/pytr/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
    mainProgram = "pytr";
  };
}
