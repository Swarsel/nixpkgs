{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  k9s,
  nix-update-script,
  testers,
  writableTmpDirAsHomeHook,
}:

buildGoModule (finalAttrs: {
  pname = "k9s";
  version = "0.51.0";

  src = fetchFromGitHub {
    owner = "derailed";
    repo = "k9s";
    tag = "v${finalAttrs.version}";
    hash = "sha256-70Rfu1BVd/QnwWXRRpwIeZ2UJNWIGixpdiOHo4v7adA=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-PkYDJK2oGl+siCG9p4R8shC0e5BhGFdJsc+ksL9J5zw=";
  # TODO investigate why some config tests are failing
  doCheck = !(stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64);
  nativeCheckInputs = [ writableTmpDirAsHomeHook ];

  postInstall = ''
    # k9s requires a writeable log directory
    # Otherwise an error message is printed
    # into the completion scripts
    export K9S_LOGS_DIR=$(mktemp -d)

    installShellCompletion --cmd k9s \
      --bash <($out/bin/k9s completion bash) \
      --fish <($out/bin/k9s completion fish) \
      --zsh <($out/bin/k9s completion zsh)

    mkdir -p $out/share/k9s/skins
    cp -r $src/skins/* $out/share/k9s/skins/
  '';

  ldflags = [
    "-s"
    "-X github.com/derailed/k9s/cmd.version=${finalAttrs.version}"
    "-X github.com/derailed/k9s/cmd.commit=${finalAttrs.src.rev}"
    "-X github.com/derailed/k9s/cmd.date=1970-01-01T00:00:00Z"
  ];

  proxyVendor = true;
  tags = [ "netcgo" ];

  # For arch != x86
  # {"level":"fatal","error":"could not create any of the following paths: /homeless-shelter/.config, /etc/xdg","time":"2022-06-28T15:52:36Z","message":"Unable to create configuration directory for k9s"}
  passthru = {
    tests.version = testers.testVersion {
      inherit (finalAttrs) version;
      command = "HOME=$(mktemp -d) k9s version -s";
      package = k9s;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Kubernetes CLI To Manage Your Clusters In Style";
    homepage = "https://github.com/derailed/k9s";
    changelog = "https://github.com/derailed/k9s/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      markus1189
      qjoly
      devusb
      ryan4yin
    ];

    mainProgram = "k9s";
  };
})
