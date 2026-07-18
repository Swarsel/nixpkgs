{
  lib,
  fetchFromGitHub,
  buildGoModule,
  gitMinimal,
  installShellFiles,
  makeWrapper,
}:

buildGoModule (finalAttrs: {
  pname = "mani";
  version = "0.32.1";

  src = fetchFromGitHub {
    owner = "alajmo";
    repo = "mani";
    tag = "v${finalAttrs.version}";
    sha256 = "sha256-895ofhRhsdDYcDHWZ4WZjgfG3pPQD6dY6KspO2rVwLk=";
  };

  nativeBuildInputs = [
    installShellFiles
    makeWrapper
  ];

  vendorHash = "sha256-EtXy+OtKRlHqNb9VqP9bI+Giv5+9yI1fj6olCcQ6xDw=";
  # Skip tests
  # The repo's test folder has a README.md with detailed information. I don't
  # know how to wrap the dependencies for these integration tests so skip for now.
  doCheck = false;

  postInstall = ''
    installShellCompletion --cmd mani \
      --bash <($out/bin/mani completion bash) \
      --fish <($out/bin/mani completion fish) \
      --zsh <($out/bin/mani completion zsh)

    wrapProgram $out/bin/mani \
      --prefix PATH : ${lib.makeBinPath [ gitMinimal ]}
  '';

  ldflags = [
    "-s"
    "-X github.com/alajmo/mani/cmd.version=${finalAttrs.version}"
  ];

  meta = {
    description = "CLI tool to help you manage multiple repositories";
    homepage = "https://manicli.com";
    changelog = "https://github.com/alajmo/mani/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ phanirithvij ];
    mainProgram = "mani";
  };
})
