{
  lib,
  fetchurl,
  fetchFromGitHub,
  buildGoModule,
  jq,
  runCommand,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "lark-cli";
  version = "1.0.58";

  src = fetchFromGitHub {
    owner = "larksuite";
    repo = "cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-MqaxcmzX/79vM2EI8wD4ZAFsUfqWvPAovlpmuDP1IWU=";
  };

  postPatch =
    let
      metaDataRaw = fetchurl {
        hash = "sha256-W6KOtDW6gkZIqGa0A5QL0rVjVkRjM+gwW4S3AddPN1M=";
        name = "meta_dataraw.json";
        url = "https://web.archive.org/web/20260626061256/https://open.feishu.cn/api/tools/open/api_definition?protocol=meta&client_version=v${finalAttrs.version}";
      };

      metaData =
        runCommand "meta_data.json"
          {
            nativeBuildInputs = [ jq ];
          }
          ''
            jq '.data' ${metaDataRaw} > $out
          '';
    in
    ''
      cp ${metaData} internal/registry/meta_data.json
    '';

  vendorHash = "sha256-M0/Y62Y+M/P1B/YIDjX5bEyB/GKihCWQakTWVd7zvBg=";

  postInstall = ''
    mv $out/bin/cli $out/bin/lark-cli
  '';

  __structuredAttrs = true;

  ldflags = [
    "-s"
    "-w"
    "-X github.com/larksuite/cli/internal/build.Version=v${finalAttrs.version}"
    "-X github.com/larksuite/cli/internal/build.Date=2026-06-01"
  ];

  subPackages = [ "." ];

  passthru.tests.version = testers.testVersion {
    version = "v${finalAttrs.version}";
    command = "lark-cli --version";
    package = finalAttrs.finalPackage;
  };

  meta = {
    description = "The official CLI for Lark/Feishu open platform";
    homepage = "https://github.com/larksuite/cli";
    changelog = "https://github.com/larksuite/cli/releases/tag/v${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ zehuajun ];
    mainProgram = "lark-cli";
  };
})
