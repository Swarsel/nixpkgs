{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  go,
  installShellFiles,
  makeWrapper,
}:

buildGoModule (finalAttrs: {
  pname = "cobra-cli";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "spf13";
    repo = "cobra-cli";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-E0I/Pxw4biOv7aGVzGlQOFXnxkc+zZaEoX1JmyMh6UE=";
  };

  postPatch = ''
    substituteInPlace "cmd/add_test.go" \
      --replace "TestGoldenAddCmd" "SkipGoldenAddCmd"
    substituteInPlace "cmd/init_test.go" \
      --replace "TestGoldenInitCmd" "SkipGoldenInitCmd"
  '';

  nativeBuildInputs = [
    makeWrapper
    installShellFiles
  ];

  vendorHash = "sha256-vrtGPQzY+NImOGaSxV+Dvch+GNPfL9XfY4lfCHTGXwY=";

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd cobra-cli \
      --bash <($out/bin/cobra-cli completion bash) \
      --fish <($out/bin/cobra-cli completion fish) \
      --zsh <($out/bin/cobra-cli completion zsh) \

    # Ironically, cobra-cli still uses old, slightly buggy completion code
    # This will correct the #compdef tag and add separate compdef line
    # allowing direct sourcing to also activate the completion
    substituteInPlace "$out/share/zsh/site-functions/_cobra-cli" \
      --replace-fail '#compdef _cobra-cli cobra-cli' "#compdef cobra-cli''\ncompdef _cobra-cli cobra-cli"
  '';

  postFixup = ''
    wrapProgram "$out/bin/cobra-cli" \
      --prefix PATH : ${go}/bin
  '';

  allowGoReference = true;

  meta = {
    description = "Cobra CLI tool to generate applications and commands";
    homepage = "https://github.com/spf13/cobra-cli/";
    changelog = "https://github.com/spf13/cobra-cli/releases/tag/${finalAttrs.version}";
    license = lib.licenses.afl20;
    maintainers = [ lib.maintainers.ivankovnatsky ];
    mainProgram = "cobra-cli";
  };
})
