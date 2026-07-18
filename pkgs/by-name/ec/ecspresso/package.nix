{
  lib,
  fetchFromGitHub,
  buildGoModule,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "ecspresso";
  version = "2.8.5";

  src = fetchFromGitHub {
    owner = "kayac";
    repo = "ecspresso";
    tag = "v${finalAttrs.version}";
    hash = "sha256-IXvCWuE1KJFCckZjGP9LvEY0S9WzrKPqPx759YIYe4A=";
  };

  vendorHash = "sha256-bvmGvJwjh1tZcKiwIBAveN0Js61/+sh+X6lrJfUYPZ0=";
  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  ldflags = [
    "-s"
    "-w"
    "-X main.buildDate=none"
    "-X github.com/kayac/ecspresso/v2.Version=${finalAttrs.version}"
  ];

  subPackages = [
    "cmd/ecspresso"
  ];

  versionCheckProgramArg = "version";

  meta = {
    description = "Deployment tool for ECS";
    homepage = "https://github.com/kayac/ecspresso/";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      FKouhai
    ];

    mainProgram = "ecspresso";
  };
})
