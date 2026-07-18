{
  lib,
  fetchFromGitHub,
  buildGo125Module,
  buildGoModule,
  installShellFiles,
  nixosTests,
}:

let
  generic =
    {
      buildGoModule,
      hash,
      license,
      vendorHash,
      version,
      ...
    }@attrs:
    let
      attrs' = removeAttrs attrs [
        "buildGoModule"
        "version"
        "hash"
        "vendorHash"
        "license"
      ];
    in
    buildGoModule (
      rec {
        inherit version vendorHash;
        pname = "nomad";

        src = fetchFromGitHub {
          inherit hash;
          owner = "hashicorp";
          repo = "nomad";
          rev = "v${version}";
        };

        nativeBuildInputs = [ installShellFiles ];

        postInstall = ''
          echo "complete -C $out/bin/nomad nomad" > nomad.bash
          installShellCompletion nomad.bash
        '';

        ldflags = [
          "-X github.com/hashicorp/nomad/version.Version=${version}"
          "-X github.com/hashicorp/nomad/version.VersionPrerelease="
          "-X github.com/hashicorp/nomad/version.BuildDate=1970-01-01T00:00:00Z"
        ];

        subPackages = [ "." ];
        # ui:
        #  Nomad release commits include the compiled version of the UI, but the file
        #  is only included if we build with the ui tag.
        tags = [ "ui" ];

        meta = {
          inherit license;
          description = "Distributed, Highly Available, Datacenter-Aware Scheduler";
          homepage = "https://developer.hashicorp.com/nomad";

          maintainers = with lib.maintainers; [
            rushmorem
            techknowlogick
            cottand
          ];

          mainProgram = "nomad";
        };
      }
      // attrs'
    );
in
rec {
  # Nomad never updates major go versions within a release series and is unsupported
  # on Go versions that it did not ship with. Due to historic bugs when compiled
  # with different versions we pin Go for all versions.
  # Upstream partially documents used Go versions here
  # https://github.com/hashicorp/nomad/blob/master/contributing/golang.md
  nomad = nomad_1_11;

  nomad_1_10 = generic {
    version = "1.10.5";
    vendorHash = "sha256-QcTw9kKwoHIvXZoxfDohFG+sBs8OLvYPeygygDClsn8=";

    preCheck = ''
      export PATH="$PATH:$NIX_BUILD_TOP/go/bin"
    '';

    buildGoModule = buildGo125Module;
    hash = "sha256-NFH++oYWb6vQN6cOPByscI/ZBWDNy4YbcLiBMO3/jVU=";
    license = lib.licenses.bsl11;
    passthru.tests.nomad = nixosTests.nomad;
  };

  nomad_1_11 = generic {
    version = "1.11.3";
    vendorHash = "sha256-67etQUjcPXz4VVpNXLVusQlEybxEqKfYQcNTNL4X8bA=";

    preCheck = ''
      export PATH="$PATH:$NIX_BUILD_TOP/go/bin"
    '';

    buildGoModule = buildGo125Module;
    hash = "sha256-J+w53HlMlrXX5yKjDYhf3rSGt1pmOyNcPlOqyUrkLWE=";
    license = lib.licenses.bsl11;
    passthru.tests.nomad = nixosTests.nomad;
  };

  nomad_1_9 = generic {
    version = "1.9.7";
    vendorHash = "sha256-9GnwqkexJAxrhW9yJFaDTdSaZ+p+/dcMuhlusp4cmyw=";

    preCheck = ''
      export PATH="$PATH:$NIX_BUILD_TOP/go/bin"
    '';

    buildGoModule = buildGo125Module;
    hash = "sha256-U02H6DPr1friQ9EwqD/wQnE2Fm20OE5xNccPDJfnsqI=";
    license = lib.licenses.bsl11;
    passthru.tests.nomad = nixosTests.nomad;
  };
}
