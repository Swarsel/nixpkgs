{
  lib,
  stdenv,
  fetchFromGitHub,
  darwin,
  installShellFiles,
  openapi-python-client,
  python3Packages,
  testers,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "openapi-python-client";
  version = "0.29.0";

  src = fetchFromGitHub {
    inherit (finalAttrs) version;
    owner = "openapi-generators";
    repo = "openapi-python-client";
    tag = "v${finalAttrs.version}";
    hash = "sha256-TxLwRi7zoFO5ejYLXllprxkiEbRtvidqjzLLpQOuQG8=";
  };

  nativeBuildInputs = [
    installShellFiles
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    darwin.ps
  ];

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    # see: https://github.com/fastapi/typer/blob/5889cf82f4ed925f92e6b0750bf1b1ed9ee672f3/typer/completion.py#L54
    # otherwise shellingham throws exception on darwin
    export _TYPER_COMPLETE_TEST_DISABLE_SHELL_DETECTION=1
    installShellCompletion --cmd openapi-python-client \
      --bash <($out/bin/openapi-python-client --show-completion bash) \
      --fish <($out/bin/openapi-python-client --show-completion fish) \
      --zsh <($out/bin/openapi-python-client --show-completion zsh)
  '';

  build-system = with python3Packages; [
    hatchling
  ];

  dependencies = (
    with python3Packages;
    [
      attrs
      httpx
      jinja2
      pydantic
      python-dateutil
      ruamel-yaml
      ruff
      shellingham
      typer
      typing-extensions
    ]
  );

  pyproject = true;
  # openapi-python-client defines upper bounds to the dependencies, ruff python library is
  # just a simple wrapper to locate the binary. We'll remove the upper bound
  pythonRelaxDeps = [ "ruff" ];

  passthru = {
    tests.version = testers.testVersion {
      package = openapi-python-client;
    };
  };

  meta = {
    description = "Generate modern Python clients from OpenAPI";
    homepage = "https://github.com/openapi-generators/openapi-python-client";
    changelog = "https://github.com/openapi-generators/openapi-python-client/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ konradmalik ];
    mainProgram = "openapi-python-client";
  };
})
