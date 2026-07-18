{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "monsoon";
  version = "0.10.1";

  src = fetchFromGitHub {
    owner = "RedTeamPentesting";
    repo = "monsoon";
    tag = "v${finalAttrs.version}";
    hash = "sha256-vgwoW7jrcLVHDm1cYrIpFcfrgKImCAVOtHg8lMQ6aic=";
  };

  vendorHash = "sha256-hGEUO1sl8IKXo4rkS81Wlf7187lu2PrSujNlGNTLwmE=";
  # Tests fails on darwin
  doCheck = !stdenv.hostPlatform.isDarwin;
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;

  ldflags = [
    "-s"
    "-X=main.version=v${finalAttrs.version}"
  ];

  versionCheckProgramArg = [ "version" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Fast HTTP enumerator";

    longDescription = ''
      A fast HTTP enumerator that allows you to execute a large number of HTTP
      requests, filter the responses and display them in real-time.
    '';

    homepage = "https://github.com/RedTeamPentesting/monsoon";
    changelog = "https://github.com/RedTeamPentesting/monsoon/releases/tag/v${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "monsoon";
  };
})
