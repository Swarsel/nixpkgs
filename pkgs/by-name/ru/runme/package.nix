{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  nodejs,
  python3,
  runme,
  runtimeShell,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "runme";
  version = "3.17.1";

  src = fetchFromGitHub {
    owner = "runmedev";
    repo = "runme";
    rev = "v${finalAttrs.version}";
    hash = "sha256-RnbyVVXxPw6w55ulhK3XIB/RPAsZqDLUXY4x/BLeAi8=";
  };

  postPatch = ''
    substituteInPlace testdata/{flags/fmt,prompts/basic,runall/basic,script/basic,tags/categories}.txtar \
      --replace-fail /bin/bash "${runtimeShell}"
  '';

  nativeBuildInputs = [
    installShellFiles
  ];

  vendorHash = "sha256-bTXLDu2oF2HcPSPeEMyLvSm2SHjfWUMfkltMUnSwxIc=";
  # checkFlags = [
  #   "-ldflags=-X=github.com/runmedev/runme/v3/internal/version.BuildVersion=${finalAttrs.version}"
  # ];
  # tests fail to access /etc/bashrc on darwin
  doCheck = !stdenv.hostPlatform.isDarwin;

  nativeCheckInputs = [
    nodejs
    python3
  ];

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd runme \
      --bash <($out/bin/runme completion bash) \
      --fish <($out/bin/runme completion fish) \
      --zsh <($out/bin/runme completion zsh)
  '';

  ldflags = [
    "-s"
    "-w"
    "-X=github.com/runmedev/runme/v3/internal/version.BuildDate=1970-01-01T00:00:00Z"
    "-X=github.com/runmedev/runme/v3/internal/version.BuildVersion=${finalAttrs.version}"
    "-X=github.com/runmedev/runme/v3/internal/version.Commit=${finalAttrs.src.rev}"
  ];

  subPackages = [
    "."
  ];

  passthru.tests = {
    version = testers.testVersion {
      package = runme;
    };
  };

  meta = {
    description = "Execute commands inside your runbooks, docs, and READMEs";
    homepage = "https://runme.dev";
    changelog = "https://github.com/runmedev/runme/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ _7karni ];
    mainProgram = "runme";
  };
})
