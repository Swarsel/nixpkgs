{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "toml-test";
  version = "2.2.0";

  src = fetchFromGitHub {
    owner = "toml-lang";
    repo = "toml-test";
    tag = "v${finalAttrs.version}";
    hash = "sha256-GqBH657RSIK7wyRRtSn5N3wAZSJazlvcw4wp2Zhbb9o=";
  };

  vendorHash = "sha256-JcTW21Zva/7Uvc5AvW9H1IxAcaw3AU0FAdtI3IOtZAc=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  ldflags = [
    "-s"
    "-w"
    "-X zgo.at/zli.version=${finalAttrs.version}"
  ];

  versionCheckProgramArg = "version";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Language agnostic test suite for TOML parsers";
    homepage = "https://github.com/toml-lang/toml-test";
    changelog = "https://github.com/toml-lang/toml-test/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      yzx9
      defelo
    ];

    mainProgram = "toml-test";
  };
})
