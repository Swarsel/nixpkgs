{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  callPackage,
  installShellFiles,
}:
let
  mkKops = callPackage ./mkkops.nix { };
in
{
  inherit mkKops;

  kops_1_31 = mkKops (finalAttrs: {
    version = "1.31.0";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-q9megrNXXKJ/YqP/fjPHh8Oji4dPK5M3HLHa+ufwRAM=";
  });

  kops_1_32 = mkKops (finalAttrs: {
    version = "1.32.1";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-nQKeTDajtUffPBhPrPuaJ+1XWgLDUltwDQDZHkylys4=";
  });

  kops_1_33 = mkKops (finalAttrs: {
    version = "1.33.0";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-VnnKWcU83yqsKW54Q1tr99/Ln8ppMyB7GLl70rUFGDY=";
  });
}
