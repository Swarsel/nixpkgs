{
  lib,
  fetchFromGitHub,
  buildGoModule,
  gopass,
  makeWrapper,
  versionCheckHook,
  writableTmpDirAsHomeHook,
}:

buildGoModule (finalAttrs: {
  pname = "gopass-hibp";
  version = "1.16.1";

  src = fetchFromGitHub {
    owner = "gopasspw";
    repo = "gopass-hibp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-BlZxXN14bOO7LMdjS/ooqVKmRZQTpNYlYp4A4rTew4Q=";
  };

  nativeBuildInputs = [ makeWrapper ];
  vendorHash = "sha256-LUmxstDE0paYaNS2Em1Xc6pJmHHWk/IJEjTZXq5qWW8=";
  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
    writableTmpDirAsHomeHook
    gopass
  ];

  postFixup = ''
    wrapProgram $out/bin/gopass-hibp \
      --prefix PATH : "${gopass.wrapperPath}"
  '';

  __darwinAllowLocalNetworking = true;

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
    "-X main.commit=${finalAttrs.src.rev}"
  ];

  preVersionCheck = ''
    gopass setup --name "user" --email "user@localhost"
  '';

  subPackages = [ "." ];
  versionCheckKeepEnvironment = [ "HOME" ];

  meta = {
    description = "Gopass haveibeenpwnd.com integration";
    homepage = "https://github.com/gopasspw/gopass-hibp";
    changelog = "https://github.com/gopasspw/gopass-hibp/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sikmir ];
    mainProgram = "gopass-hibp";
  };
})
