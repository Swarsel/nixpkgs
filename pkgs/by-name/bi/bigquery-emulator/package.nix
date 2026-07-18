{
  lib,
  fetchFromGitHub,
  buildGoModule,
  pkgs,
}:

buildGoModule.override
  {
    stdenv = pkgs.clangStdenv;
  }
  (finalAttrs: {
    pname = "bigquery-emulator";
    version = "0.6.6";

    src = fetchFromGitHub {
      owner = "goccy";
      repo = "bigquery-emulator";
      tag = "v${finalAttrs.version}";
      hash = "sha256-iAVbxbm1G7FIWTB5g6Ff8h2dZjZssONA2MOCGuvK180=";
    };

    postPatch = ''
      # main module does not contain package
      rm -r internal/cmd/generator
    '';

    vendorHash = "sha256-TQlsivudutyPFW+3HHX7rYuoB5wafmDTAO1TElO/8pc=";
    doCheck = false;
    ldflags = [ "-s -w -X main.version=${finalAttrs.version} -X main.revision=v${finalAttrs.version}" ];

    meta = {
      description = "BigQuery emulator server implemented in Go";
      homepage = "https://github.com/goccy/bigquery-emulator";
      changelog = "https://github.com/goccy/bigquery-emulator/releases/tag/v${finalAttrs.version}";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [ tarantoj ];
      mainProgram = "bigquery-emulator";
    };
  })
