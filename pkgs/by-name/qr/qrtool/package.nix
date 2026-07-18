{
  lib,
  stdenv,
  fetchFromGitHub,
  asciidoctor,
  installShellFiles,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "qrtool";
  version = "0.13.2";

  src = fetchFromGitHub {
    owner = "sorairolake";
    repo = "qrtool";
    tag = "v${finalAttrs.version}";
    hash = "sha256-N/kxis/nLwl+cfmlIC0TzZe0nApp160VXWoWeDtOctU=";
  };

  nativeBuildInputs = [
    asciidoctor
    installShellFiles
  ];

  cargoHash = "sha256-PgtVl55gpVsDg3VMuqtQaR7hD2ebL5+ffLNdpHggxfg=";

  postInstall = ''
    asciidoctor -b manpage docs/man/man1/*.1.adoc
    installManPage docs/man/man1/*.1
  ''
  + lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd qrtool \
      --bash <($out/bin/qrtool completion bash) \
      --fish <($out/bin/qrtool completion fish) \
      --zsh <($out/bin/qrtool completion zsh)
  '';

  meta = {
    description = "Utility for encoding and decoding QR code images";
    homepage = "https://sorairolake.github.io/qrtool/book/index.html";
    changelog = "https://sorairolake.github.io/qrtool/book/changelog.html";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ philiptaron ];
    mainProgram = "qrtool";
  };
})
