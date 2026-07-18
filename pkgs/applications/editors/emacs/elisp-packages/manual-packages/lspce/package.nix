{
  lib,
  callPackage,
  f,
  markdown-mode,
  melpaBuild,
  yasnippet,
}:

let
  lspce-module = callPackage ./module.nix { };
in
melpaBuild {
  inherit (lspce-module) version src meta;
  pname = "lspce";
  # to compile lspce.el, it needs lspce-module.so
  files = ''(:defaults "${lib.getLib lspce-module}/lib/lspce-module.*")'';

  packageRequires = [
    f
    markdown-mode
    yasnippet
  ];

  passthru = {
    inherit lspce-module;
  };
}
