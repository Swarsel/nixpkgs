{
  lib,
  fetchFromGitHub,
  buildGoModule,
  llvmPackages,
  nix-update-script,
  versionCheckHook,
}:

buildGoModule rec {
  pname = "mactop";
  version = "2.1.3";

  src = fetchFromGitHub {
    owner = "metaspartan";
    repo = "mactop";
    tag = "v${version}";
    hash = "sha256-rWALbjy7s6X3hegcUxoR0XUXKFZGnWRWV5OeXtN3BjU=";
  };

  nativeBuildInputs = [ llvmPackages.lld ];
  vendorHash = "sha256-TF66wg8nyAb/kZ80XLaD7H39EehZQ896DS6Ce3+P8Lk=";

  env = {
    # Work around ld64's libc++ hardening issue.
    # TODO: Remove once #536365 reaches this branch.
    NIX_CFLAGS_LINK = "-fuse-ld=lld";
  };

  doCheck = false;
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  ldflags = [
    "-s"
    "-w"
  ];

  proxyVendor = true;
  versionCheckProgramArg = "--version";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Terminal-based monitoring tool 'top' designed to display real-time metrics for Apple Silicon chips";
    homepage = "https://github.com/metaspartan/mactop";
    changelog = "https://github.com/metaspartan/mactop/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ natsukium ];
    platforms = [ "aarch64-darwin" ];
    mainProgram = "mactop";
  };
}
