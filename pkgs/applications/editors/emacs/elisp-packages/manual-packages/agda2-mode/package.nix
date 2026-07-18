{ haskellPackages, melpaBuild }:
let
  Agda = haskellPackages.Agda;
in
melpaBuild {
  inherit (Agda) src version;
  pname = "agda2-mode";
  files = ''("src/data/emacs-mode/*.el")'';

  meta = {
    inherit (Agda.meta) homepage license;
    description = "Agda2-mode for Emacs extracted from Agda package";
  };
}
