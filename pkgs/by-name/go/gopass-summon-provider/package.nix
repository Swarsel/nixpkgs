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
  pname = "gopass-summon-provider";
  version = "1.16.1";

  src = fetchFromGitHub {
    owner = "gopasspw";
    repo = "gopass-summon-provider";
    tag = "v${finalAttrs.version}";
    hash = "sha256-j3N/snUCsw/NlMQO9CoVRf6JCG48DEHqrJnZ7wiVUPk=";
  };

  nativeBuildInputs = [ makeWrapper ];
  vendorHash = "sha256-FhS79dSY9FjlScoXd6EbYRRwEBObZLO9g/SXBEXQpjM=";
  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
    writableTmpDirAsHomeHook
    gopass
  ];

  postFixup = ''
    wrapProgram $out/bin/gopass-summon-provider \
      --prefix PATH : "${gopass.wrapperPath}"
  '';

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
    description = "Gopass Summon Provider";
    homepage = "https://github.com/gopasspw/gopass-summon-provider";
    changelog = "https://github.com/gopasspw/gopass-summon-provider/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sikmir ];
    mainProgram = "gopass-summon-provider";
  };
})
