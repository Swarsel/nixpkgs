{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
}:

buildGoModule (finalAttrs: {
  pname = "libgen-cli";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "ciehanski";
    repo = "libgen-cli";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-EicXsxAvVe/umpcOn4dVlTexaAol1qYPg/h5MU5dysM=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-q1EPjnVq382gEKVmGKWYgKRcU6Y0rm1Et5ExzOmyeo4=";
  doCheck = false;

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd libgen-cli \
      --bash <($out/bin/libgen-cli completion bash) \
      --fish <($out/bin/libgen-cli completion fish) \
      --zsh <($out/bin/libgen-cli completion zsh)
  '';

  ldflags = [
    "-s"
    "-w"
  ];

  subPackages = [ "." ];

  meta = {
    description = "CLI tool used to access the Library Genesis dataset; written in Go";

    longDescription = ''
      libgen-cli is a command line interface application which allows users to
      quickly query the Library Genesis dataset and download any of its
      contents.
    '';

    homepage = "https://github.com/ciehanski/libgen-cli";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ zaninime ];
    mainProgram = "libgen-cli";
  };
})
