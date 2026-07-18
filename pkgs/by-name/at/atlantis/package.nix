{
  lib,
  fetchFromGitHub,
  buildGoModule,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "atlantis";
  version = "0.46.0";

  src = fetchFromGitHub {
    owner = "runatlantis";
    repo = "atlantis";
    tag = "v${finalAttrs.version}";
    hash = "sha256-4twWPp+ZgK6YmNL5RJmLKhtxe33T1GDCu1qejUbqXkA=";
  };

  vendorHash = "sha256-/PnEQvaqADxwFvrHWOPFopQwdyUXBa6cf/H7a/RaHcg=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  ldflags = [
    "-X=main.version=${finalAttrs.version}"
    "-X=main.date=1970-01-01T00:00:00Z"
  ];

  subPackages = [ "." ];
  versionCheckProgram = "${placeholder "out"}/bin/atlantis";
  versionCheckProgramArg = "version";

  meta = {
    description = "Terraform Pull Request Automation";
    homepage = "https://github.com/runatlantis/atlantis";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      tebriel
    ];

    mainProgram = "atlantis";
  };
})
