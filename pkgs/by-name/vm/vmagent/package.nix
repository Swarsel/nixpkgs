{ lib, victoriametrics }:

# This package is build out of the victoriametrics package.
# so no separate update prs are needed for vmagent
# nixpkgs-update: no auto update
lib.addMetaAttrs { mainProgram = "vmagent"; } (
  victoriametrics.override {
    withBackupTools = false;
    withServer = false;
    withVmAgent = true;
    withVmAlert = false;
    withVmAuth = false;
    withVmctl = false;
  }
)
