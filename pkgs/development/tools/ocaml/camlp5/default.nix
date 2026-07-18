{
  lib,
  stdenv,
  fetchFromGitHub,
  bos,
  camlp-streams,
  findlib,
  fmt,
  makeWrapper,
  ocaml,
  pcre2,
  perl,
  re,
  rresult,
  legacy ? false,
}:

stdenv.mkDerivation (
  finalAttrs:
  let
    recent = lib.versionAtLeast (lib.versions.major finalAttrs.version) "8";
  in
  {

    pname = "ocaml${ocaml.version}-camlp5";
    version = if lib.versionAtLeast ocaml.version "4.12" && !legacy then "8.05.02" else "7.14";

    src = fetchFromGitHub {
      owner = "camlp5";
      repo = "camlp5";

      tag =
        if recent then
          finalAttrs.version
        else
          "rel${builtins.replaceStrings [ "." ] [ "" ] finalAttrs.version}";

      hash =
        {
          "7.14" = "sha256-/ORtS0uc/GN+g3y6N5ftjL4OBSqV6iswLRbfpeNCprU=";
          "8.03.2" = "sha256-nz+VfGR/6FdBvMzPPpVpviAXXBWNqM3Ora96Yzx964o=";
          "8.05.02" = "sha256-OnTc4Vpr2I3sFwm5JYxud9z1hbzDvQw3LNsO/EHa3k8=";
        }
        ."${finalAttrs.version}";
    };

    strictDeps = true;

    nativeBuildInputs = [
      ocaml
      perl
    ]
    ++ lib.optionals recent [
      makeWrapper
      findlib
    ];

    buildInputs = lib.optionals recent [
      bos
      re
      rresult
    ];

    propagatedBuildInputs = lib.optionals recent [
      camlp-streams
      pcre2
      fmt
    ];

    buildFlags = [ "world.opt" ];

    preConfigure = ''
      configureFlagsArray=(--strict --libdir $out/lib/ocaml/${ocaml.version}/site-lib)
      patchShebangs ./config/find_stuffversion.pl etc/META.pl tools/ ocaml_src/tools/
    '';

    postInstall = lib.optionalString recent ''
      for prog in camlp5 camlp5o camlp5r camlp5sch mkcamlp5 ocpp5
      do
        wrapProgram $out/bin/$prog \
          --prefix CAML_LD_LIBRARY_PATH : "$CAML_LD_LIBRARY_PATH"
      done
    '';

    dontStrip = true;
    prefixKey = "-prefix ";

    meta = {
      description = "Preprocessor-pretty-printer for OCaml";

      longDescription = ''
        Camlp5 is a preprocessor and pretty-printer for OCaml programs.
        It also provides parsing and printing tools.
      '';

      homepage = "https://camlp5.github.io/";
      license = lib.licenses.bsd3;
      maintainers = [ lib.maintainers.vbgl ];
      platforms = ocaml.meta.platforms or [ ];
      broken = lib.versionAtLeast ocaml.version "5.4" && !lib.versionAtLeast finalAttrs.version "8.04.00";
    };
  }
)
