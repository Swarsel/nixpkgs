{ lib
, buildGoModule
, fetchFromGitHub
, versionCheckHook
, mockgen
, go_1_25
}:
buildGo125Module (finalAttrs: {
  pname = "terragrunt";
  version = "0.97.0";

  src = fetchFromGitHub {
    owner = "gruntwork-io";
    repo = "terragrunt";
    tag = "v${finalAttrs.version}";
    hash = "sha256-LJGc85oCDEW/z9I4Mcr9Pyv9MLqqN4Zu/nJK1LTD9mk=";
  };

      nativeBuildInputs = [
        versionCheckHook
        mockgen
      ];

      preBuild = ''
    make generate-mocks
      '';

  vendorHash = "sha256-BXFtw7+f9Isnk6EB3U4eLlho5B3rTnofmWBDbbbroUs=";

      doCheck = false;

      ldflags = [
        "-s"
        "-w"
        "-X github.com/gruntwork-io/go-commons/version.Version=v${finalAttrs.version}"
        "-extldflags '-static'"
      ];

      doInstallCheck = true;

      meta = with lib; {
        homepage = "https://terragrunt.gruntwork.io";
        changelog = "https://github.com/gruntwork-io/terragrunt/releases/tag/v${finalAttrs.version}";
        description = "Thin wrapper for Terraform that supports locking for Terraform state and enforces best practices";
        mainProgram = "terragrunt";
        license = licenses.mit;
        maintainers = with maintainers; [
          jk
          qjoly
          kashw2
        ];
      };
    })
