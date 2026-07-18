{
  buildDunePackage,
  fetchpatch,
  ocf,
  ppxlib,
}:

buildDunePackage {
  inherit (ocf) src version;
  pname = "ocf_ppx";

  patches = [
    # Support for ppxlib ≥ 0.37
    (fetchpatch {
      hash = "sha256-GymTdK/dOYGianvNIKkl9OhBGW+4dX5TqAkQuEF5FmA=";
      includes = [ "*.ml" ];
      url = "https://framagit.org/zoggy/ocf/-/commit/38b1f6420e5c01b3ea6b2fed99b6b62e4c848dc0.patch";
    })
  ];

  buildInputs = [
    ppxlib
    ocf
  ];

  minimalOCamlVersion = "4.11";

  meta = ocf.meta // {
    description = "Preprocessor for Ocf library";
  };
}
