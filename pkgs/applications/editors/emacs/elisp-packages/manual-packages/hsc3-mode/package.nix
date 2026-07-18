{
  haskell-mode,
  haskellPackages,
  melpaBuild,
}:

let
  inherit (haskellPackages) hsc3;
in
melpaBuild {
  inherit (hsc3) src version;
  pname = "hsc3-mode";
  ename = "hsc3";
  files = ''("emacs/*.el")'';
  packageRequires = [ haskell-mode ];

  meta = {
    inherit (hsc3.meta) homepage license;
    description = "Emacs mode for hsc3";
  };
}
