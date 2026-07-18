{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "helmify";
  version = "0.4.20";

  src = fetchFromGitHub {
    owner = "arttor";
    repo = "helmify";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Az/rNrNwWkQCZ8iy2qkix8xqsWA+eUbFw7YstA9usdw=";
  };

  vendorHash = "sha256-a2uA2P9eenpgb2bFMvy3ioI9crG0FpvD1vEXqCwwwyw=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;

  ldflags = [
    "-s"
    "-X main.version=${finalAttrs.version}"
    "-X main.commit=${finalAttrs.src.tag}"
    "-X main.date=19700101"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Creates Helm chart from Kubernetes yaml";
    homepage = "https://github.com/arttor/helmify";
    changelog = "https://github.com/arttor/helmify/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jlesquembre ];
    platforms = lib.platforms.unix;
    mainProgram = "helmify";
  };
})
