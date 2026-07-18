{
  lib,
  fetchFromGitHub,
  buildGoModule,
  versionCheckHook,
  writableTmpDirAsHomeHook,
}:

buildGoModule (finalAttrs: {
  pname = "squix";
  version = "0.5.0-beta";

  src = fetchFromGitHub {
    owner = "eduardofuncao";
    repo = "squix";
    rev = "v${finalAttrs.version}";
    hash = "sha256-R/y1fl4MehZ+VDWBtSL3EDzVBsAdCeR5nS687vwk1IM=";
  };

  vendorHash = "sha256-kSv3VAQi+qdT29gZAjLmHauItaMFd9NG7bdRtQE1MZo=";
  doInstallCheck = true;

  nativeInstallCheckInputs = [
    writableTmpDirAsHomeHook
    versionCheckHook
  ];

  __structuredAttrs = true;

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${finalAttrs.version}"
  ];

  versionCheckKeepEnvironment = [ "HOME" ];

  meta = {
    description = "SQL command-line client with query management and interactive results";
    homepage = "https://github.com/eduardofuncao/squix";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ eduardofuncao ];
    mainProgram = "squix";
  };
})
