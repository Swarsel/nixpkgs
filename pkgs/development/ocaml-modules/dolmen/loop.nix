{
  lib,
  buildDunePackage,
  dolmen,
  dolmen_type,
  gen,
  mdx,
  ocaml,
  pp_loc,
}:

buildDunePackage {
  inherit (dolmen) src version;
  pname = "dolmen_loop";

  propagatedBuildInputs = [
    dolmen
    dolmen_type
    gen
    pp_loc
  ];

  env =
    # Fix build with gcc15
    lib.optionalAttrs
      (
        lib.versionAtLeast ocaml.version "4.10" && lib.versionOlder ocaml.version "4.14"
        || lib.versions.majorMinor ocaml.version == "5.0"
      )
      {
        NIX_CFLAGS_COMPILE = "-std=gnu11";
      };

  doCheck = true;
  nativeCheckInputs = [ mdx.bin ];
  checkInputs = [ mdx ];

  meta = dolmen.meta // {
    description = "Tool library for automated deduction tools";
  };
}
