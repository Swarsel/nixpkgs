with import <localpkgs> { };
let
  inherit (vimUtils.override { inherit vim; }) buildVimPlugin;

  generated = callPackage <localpkgs/pkgs/applications/editors/vim/plugins/generated.nix> {
    inherit buildVimPlugin;
  } { } { };

  hasChecksum =
    value:
    lib.isAttrs value
    && lib.hasAttrByPath [
      "src"
      "outputHash"
    ] value;

  parse = _name: value: {
    inherit (value) pname version;

    checksum =
      if hasChecksum value then
        {
          inherit (value.src) rev;
          sha256 = value.src.outputHash;
          submodules = value.src.fetchSubmodules or false;
          tag = value.src.tag or null;
        }
      else
        null;

    homePage = value.meta.homepage;
    license = value.meta.license.spdxId or null;
  };
in
lib.mapAttrs parse generated
