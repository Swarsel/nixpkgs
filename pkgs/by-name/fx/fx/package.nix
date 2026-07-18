{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  versionCheckHook,
  writableTmpDirAsHomeHook,
}:

buildGoModule (finalAttrs: {
  pname = "fx";
  version = "39.2.0";

  src = fetchFromGitHub {
    owner = "antonmedv";
    repo = "fx";
    tag = finalAttrs.version;
    hash = "sha256-sQnawn5My511IsxBMh6r06R2aLKGmF0ndP1alr/Y8vw=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-C4TqFRECIFzc6TyAJ2yj97t2BVHXBovIV3iIjNhm7ek=";

  checkFlags = lib.optionals (stdenv.hostPlatform.system == "x86_64-darwin") [
    # flaky only on x86_64 darwin, https://hydra.nixos.org/build/319903711
    "-skip=^TestSearchCaching"
  ];

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd fx \
      --bash <($out/bin/fx --comp bash) \
      --fish <($out/bin/fx --comp fish) \
      --zsh <($out/bin/fx --comp zsh)
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
    writableTmpDirAsHomeHook
  ];

  ldflags = [ "-s" ];
  versionCheckKeepEnvironment = [ "HOME" ];

  meta = {
    description = "Terminal JSON viewer";
    homepage = "https://github.com/antonmedv/fx";
    changelog = "https://github.com/antonmedv/fx/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ phanirithvij ];
    mainProgram = "fx";
  };
})
