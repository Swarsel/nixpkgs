{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

let
  generic =
    {
      mainProgram,
      pname,
      subPackages,
      postInstall ? "",
    }:
    buildGoModule rec {
      inherit pname;
      inherit subPackages postInstall;
      version = "6.14.2";

      src = fetchFromGitHub {
        owner = "sensu";
        repo = "sensu-go";
        rev = "v${version}";
        sha256 = "sha256-DlJneEAmkWqM5SgbUvvFmiSZzapQd+IpMivlB9r47W8=";
      };

      vendorHash = "sha256-iNIpUABozQpnBUiWBrp2ii4mNRKKJtChLiHnlaEQqvU=";
      doCheck = false;

      ldflags =
        let
          versionPkg = "github.com/sensu/sensu-go/version";
        in
        [
          "-X ${versionPkg}.Version=${version}"
          "-X ${versionPkg}.BuildSHA=${shortRev}"
        ];

      shortRev = "591ed6e"; # for internal version info

      meta = {
        inherit mainProgram;
        description = "Open source monitoring tool for ephemeral infrastructure & distributed applications";
        homepage = "https://sensu.io";
        license = lib.licenses.mit;

        maintainers = with lib.maintainers; [
          thefloweringash
        ];
      };
    };
in
{
  sensu-go-agent = generic {
    pname = "sensu-go-agent";
    mainProgram = "sensu-agent";
    subPackages = [ "cmd/sensu-agent" ];
  };

  sensu-go-backend = generic {
    pname = "sensu-go-backend";
    mainProgram = "sensu-backend";
    subPackages = [ "cmd/sensu-backend" ];
  };

  sensu-go-cli = generic {
    pname = "sensu-go-cli";

    postInstall = ''
      mkdir -p \
        "''${!outputBin}/share/bash-completion/completions" \
        "''${!outputBin}/share/zsh/site-functions"

      ''${!outputBin}/bin/sensuctl completion bash > ''${!outputBin}/share/bash-completion/completions/sensuctl

      # https://github.com/sensu/sensu-go/issues/3132
      (
        echo "#compdef sensuctl"
        ''${!outputBin}/bin/sensuctl completion zsh
        echo '_complete sensuctl 2>/dev/null'
      ) > ''${!outputBin}/share/zsh/site-functions/_sensuctl

    '';

    mainProgram = "sensuctl";
    subPackages = [ "cmd/sensuctl" ];
  };
}
