{
  lib,
  fetchFromGitHub,
  buildGoModule,
  git,
  installShellFiles,
  writableTmpDirAsHomeHook,
}:

buildGoModule (finalAttrs: {
  pname = "ralphex";
  version = "1.6.0";

  src = fetchFromGitHub {
    owner = "umputun";
    repo = "ralphex";
    tag = "v${finalAttrs.version}";
    hash = "sha256-RUl5BVGc5EjeXZNjfC2WVZrrSXxR1mQyABkIxIT2NyQ=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = null;

  nativeCheckInputs = [
    git
    writableTmpDirAsHomeHook
  ];

  postInstall = ''
    installShellCompletion completions/*
  '';

  __darwinAllowLocalNetworking = true;
  __structuredAttrs = true;

  ldflags = [
    "-s"
    "-w"
    "-X main.revision=${finalAttrs.version}"
  ];

  meta = {
    description = "Extended Ralph loop for autonomous AI-driven plan execution";
    homepage = "https://ralphex.com/";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sikmir ];
    mainProgram = "ralphex";
  };
})
