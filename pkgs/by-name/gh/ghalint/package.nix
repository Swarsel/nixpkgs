{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "ghalint";
  version = "1.5.6";

  src = fetchFromGitHub {
    owner = "suzuki-shunsuke";
    repo = "ghalint";
    tag = "v${finalAttrs.version}";
    hash = "sha256-u85vX9lg5JKUvRjFloE4KZUm/qs8RmjoY/hybtJk/kc=";
  };

  nativeBuildInputs = [
    installShellFiles
  ];

  vendorHash = "sha256-n++Rq79KHyRVhIXIdN9IOADTGEG73Wl2SUq/YEo++WM=";
  env.CGO_ENABLED = 0;

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd 'ghalint' \
      --bash <("$out/bin/ghalint" completion bash) \
      --zsh <("$out/bin/ghalint" completion zsh) \
      --fish <("$out/bin/ghalint" completion fish)
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
    "-X main.commit=v${finalAttrs.version}"
  ];

  subPackages = [ "cmd/ghalint" ];
  versionCheckProgramArg = "version";

  meta = {
    description = "GitHub Actions linter for security best practice";
    homepage = "https://github.com/suzuki-shunsuke/ghalint";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ryota2357 ];
    mainProgram = "ghalint";
  };
})
