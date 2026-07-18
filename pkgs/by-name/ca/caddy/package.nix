{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  caddy,
  callPackage,
  installShellFiles,
  nixosTests,
  testers,
  versionCheckHook,
  writableTmpDirAsHomeHook,
}:

buildGoModule (finalAttrs: {
  pname = "caddy";
  version = "2.11.4";

  src = fetchFromGitHub {
    owner = "caddyserver";
    repo = "caddy";
    tag = "v${finalAttrs.version}";
    # remember to update hashes for `dist` and `plugins` test!
    hash = "sha256-wzk8KRZfDCbbjRlBwkoKAoMjOhV4xF3yuXUueqtl1xM=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-2GwSM7EKN9GwN6kte7CekpXIJ0vzHhhsnrs3TC6vTW4=";
  nativeCheckInputs = [ writableTmpDirAsHomeHook ];

  postInstall = ''
    install -Dm644 ${finalAttrs.passthru.dist}/init/caddy.service ${finalAttrs.passthru.dist}/init/caddy-api.service -t $out/lib/systemd/system

    substituteInPlace $out/lib/systemd/system/caddy.service \
      --replace-fail "/usr/bin/caddy" "$out/bin/caddy"
    substituteInPlace $out/lib/systemd/system/caddy-api.service \
      --replace-fail "/usr/bin/caddy" "$out/bin/caddy"
  ''
  + lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    # Generating man pages and completions fail on cross-compilation
    # https://github.com/NixOS/nixpkgs/issues/308283

    $out/bin/caddy manpage --directory manpages
    installManPage manpages/*

    installShellCompletion --cmd caddy \
      --bash <($out/bin/caddy completion bash) \
      --fish <($out/bin/caddy completion fish) \
      --zsh <($out/bin/caddy completion zsh)
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    writableTmpDirAsHomeHook
    versionCheckHook
  ];

  __darwinAllowLocalNetworking = true;
  __structuredAttrs = true;

  ldflags = [
    "-s"
    "-w"
    "-X github.com/caddyserver/caddy/v2.CustomVersion=${finalAttrs.version}"
  ];

  # matches upstream since v2.8.0
  tags = [
    "nobadger"
    "nomysql"
    "nopgx"
  ];

  versionCheckKeepEnvironment = [ "HOME" ];

  passthru = {
    dist = fetchFromGitHub {
      hash = "sha256-oRQfQH1GKjAjVMj+dZo1f1+HOaOdJIyEfod0iGLYcc8=";
      owner = "caddyserver";
      repo = "dist";
      tag = "v${finalAttrs.version}";
    };

    tests = {
      inherit (nixosTests) caddy;
      acme-integration = nixosTests.acme.caddy;
      plugins = testers.runNixOSTest ./plugins.test.nix;
    };

    withPlugins = callPackage ./plugins.nix { inherit caddy; };
  };

  meta = {
    description = "Fast and extensible multi-platform HTTP/1-2-3 web server with automatic HTTPS";
    homepage = "https://caddyserver.com";
    changelog = "https://github.com/caddyserver/caddy/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      stepbrobd
      techknowlogick
      ryan4yin
    ];

    mainProgram = "caddy";
  };
})
