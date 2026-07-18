{ lib, OVMF }:

(OVMF.override {
  fwPrefix = "OVMF";
  metaPlatforms = builtins.filter (lib.hasPrefix "x86_64-") OVMF.meta.platforms;
  projectDscPath = "OvmfPkg/OvmfXen.dsc";
}).overrideAttrs
  (oldAttrs: {
    pname = "OVMF-xen";
    __structuredAttrs = true;

    meta = oldAttrs.meta // {
      description = "Sample UEFI firmware for Xen guests";
      teams = [ lib.teams.xen ];
    };
  })
