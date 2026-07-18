{
  lib,
  fetchFromGitHub,
  buildGoModule,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "argo-expr";
  version = "1.1.3";

  src = fetchFromGitHub {
    owner = "blacha";
    repo = "argo-expr";
    rev = "v${finalAttrs.version}";
    hash = "sha256-XQnPFzT3PRmKeAQXLzBE5R2VvXotzxmsq+u9u5iE1QA=";
  };

  vendorHash = "sha256-HGmJVxmAj9ijsWX+qJ7J9l3uO7WvXtRU2gvx2G7N7/M=";
  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  ldflags = [ "-X main.Version=v${finalAttrs.version}" ];

  meta = {
    description = "Argo expression tester";
    homepage = "https://github.com/blacha/argo-expr";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ l0b0 ];
    mainProgram = "argo-expr";
  };
})
