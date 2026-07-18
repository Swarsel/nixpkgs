{
  lib,
  curl,
  git,
  gnugrep,
  gnused,
  jq,
  nix-update,
  writeShellScript,
}:

writeShellScript "update-esphome" ''
  PATH=${
    lib.makeBinPath [
      curl
      gnugrep
      gnused
      jq
      git
      nix-update
    ]
  }

  LATEST=$(curl https://api.github.com/repos/esphome/esphome/releases/latest | jq -r '.name')
  echo "Latest version: $LATEST"

  DASHBOARD_VERSION=$(curl https://raw.githubusercontent.com/esphome/esphome/$LATEST/requirements.txt | \
    grep "esphome-dashboard==" | sed "s/.*=//")
  echo "Dashboard version: $DASHBOARD_VERSION"

  nix-update esphome.dashboard --version $DASHBOARD_VERSION
  nix-update esphome --version $LATEST
''
