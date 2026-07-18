{
  lib,
  newScope,
  useMupdf ? true,
}:

lib.makeScope newScope (
  self:
  let
    inherit (self) callPackage;
  in
  {
    inherit useMupdf;
    zathuraWrapper = callPackage ./wrapper.nix { };
    zathura_cb = callPackage ./cb { };
    zathura_core = callPackage ./core { };
    zathura_djvu = callPackage ./djvu { };
    zathura_pdf_mupdf = callPackage ./pdf-mupdf { };
    zathura_pdf_poppler = callPackage ./pdf-poppler { };
    zathura_ps = callPackage ./ps { };
  }
)
