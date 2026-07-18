{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
}:
buildGoModule (finalAttrs: {
  pname = "devbox";
  version = "0.17.5";

  src = fetchFromGitHub {
    owner = "jetify-com";
    repo = "devbox";
    tag = finalAttrs.version;
    hash = "sha256-m7FMUjKZZsmnjtnjPyyq0YUIjDQiyb5zBbpGiH4cdyw=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-zZUE0J6w1QbdMAKOt1xH3ql4G5FbaUgtD4Xpsw/tmIk=";
  # integration tests want file system access
  doCheck = false;

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd devbox \
      --bash <($out/bin/devbox completion bash) \
      --fish <($out/bin/devbox completion fish) \
      --zsh <($out/bin/devbox completion zsh)
  '';

  ldflags = [
    "-s"
    "-w"
    "-X go.jetify.com/devbox/internal/build.Version=${finalAttrs.version}"
  ];

  subPackages = [ "cmd/devbox" ];

  meta = {
    description = "Instant, easy, predictable shells and containers";
    homepage = "https://www.jetify.com/devbox";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      lagoja
      madeddie
    ];
  };
})
