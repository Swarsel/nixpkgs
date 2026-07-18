{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "talosctl";
  version = "1.13.5";

  src = fetchFromGitHub {
    owner = "siderolabs";
    repo = "talos";
    tag = "v${finalAttrs.version}";
    hash = "sha256-woMLG4m7snKD3naTZWYEu78zC/eK5lDxd+uLyXdkzMo=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-98jQJ7M/3ki5L6YQAxtk3bBnixfXhLX4WXY7DN4hsQ4=";
  doCheck = false; # no tests

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd talosctl \
      --bash <($out/bin/talosctl completion bash) \
      --fish <($out/bin/talosctl completion fish) \
      --zsh <($out/bin/talosctl completion zsh)
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  ldflags = [
    "-s"
    "-w"
  ];

  overrideModAttrs = _: {
    buildPhase = ''
      go work vendor
    '';
  };

  subPackages = [ "cmd/talosctl" ];
  versionCheckProgramArg = "version";

  meta = {
    description = "CLI for out-of-band management of Kubernetes nodes created by Talos";
    homepage = "https://www.talos.dev/";
    license = lib.licenses.mpl20;

    maintainers = with lib.maintainers; [
      johanot
    ];

    mainProgram = "talosctl";
  };
})
