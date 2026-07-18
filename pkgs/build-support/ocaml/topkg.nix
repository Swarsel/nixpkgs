{
  lib,
  stdenv,
  fetchurl,
  b0,
  cmdliner,
  findlib,
  ocaml,
  ocamlbuild,
  odoc,
  topkg,
}:

{
  pname,
  version,
  buildInputs ? [ ],
  nativeBuildInputs ? [ ],
  ...
}@args:

if (args ? minimalOCamlVersion && lib.versionOlder ocaml.version args.minimalOCamlVersion) then
  throw "${pname}-${version} is not available for OCaml ${ocaml.version}"
else
  stdenv.mkDerivation (
    {

      inherit (topkg) buildPhase installPhase;
      strictDeps = true;
      configurePlatforms = [ ];
      dontAddStaticConfigureFlags = true;

    }
    // (removeAttrs args [ "minimalOCamlVersion" ])
    // {

      nativeBuildInputs = [
        ocaml
        findlib
        ocamlbuild
        topkg
      ]
      ++ nativeBuildInputs;

      buildInputs = [ topkg ] ++ buildInputs;
      name = "ocaml${ocaml.version}-${pname}-${version}";

      meta = (args.meta or { }) // {
        platforms = args.meta.platforms or ocaml.meta.platforms;
      };

    }
  )
