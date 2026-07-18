{
  lib,
  fetchFromGitHub,
  buildGoModule,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "nhost-cli";
  version = "1.42.1";

  src = fetchFromGitHub {
    owner = "nhost";
    repo = "nhost";
    tag = "cli@${finalAttrs.version}";
    hash = "sha256-n61YgU1/Ad1NMZr/1/jnmuZpN8PemPUW/gomf+ETvRw=";
  };

  vendorHash = null;
  # require network access
  checkFlags = [ "-skip=^TestMakeJSONRequest$" ];

  postInstall = ''
    mv $out/bin/cli $out/bin/nhost
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  ldflags = [
    "-s"
    "-X=main.Version=v${finalAttrs.version}"
  ];

  sourceRoot = "${finalAttrs.src.name}/cli";

  meta = {
    description = "Tool for setting up a local development environment for Nhost";
    homepage = "https://github.com/nhost/cli";
    changelog = "https://github.com/nhost/nhost/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
    mainProgram = "nhost";
  };
})
