{
  lib,
  stdenv,
  fetchurl,
  buildTopkgPackage,
  cmdliner,
  fmt,
  js_of_ocaml-compiler,
  lwt,
  ocaml,
  topkg,
  cmdlinerSupport ? true,
  fmtSupport ? lib.versionAtLeast ocaml.version "4.08",
  jsooSupport ? true,
  lwtSupport ? true,
  version ? if lib.versionAtLeast ocaml.version "4.14" then "0.10.0" else "0.8.0",
}:
let
  param =
    {
      "0.10.0" = {
        hash = "sha256-dg7CkcEo11t0gmCRM3dk+SW1ykFLAuLTNqCze/MN9Oo=";
        minimalOCamlVersion = "4.14";
      };

      "0.8.0" = {
        hash = "sha256-mmFRQJX6QvMBIzJiO2yNYF1Ce+qQS2oNF3+OwziCNtg=";
        minimalOCamlVersion = "4.03";
      };
    }
    .${version};

  pname = "logs";
  webpage = "https://erratique.ch/software/${pname}";

  optional_deps = [
    {
      enable_flag = "--with-js_of_ocaml-compiler";
      enabled = jsooSupport;
      pkg = js_of_ocaml-compiler;
    }
    {
      enable_flag = "--with-fmt";
      enabled = fmtSupport;
      pkg = fmt;
    }
    {
      enable_flag = "--with-lwt";
      enabled = lwtSupport;
      pkg = lwt;
    }
    {
      enable_flag = "--with-cmdliner";
      enabled = cmdlinerSupport;
      pkg = cmdliner;
    }
  ];
  enable_flags = lib.concatMap (d: [
    d.enable_flag
    (lib.boolToString d.enabled)
  ]) optional_deps;
  optional_buildInputs = map (d: d.pkg) (lib.filter (d: d.enabled) optional_deps);
in
buildTopkgPackage {
  inherit pname version;
  inherit (param) minimalOCamlVersion;

  src = fetchurl {
    inherit (param) hash;
    url = "${webpage}/releases/${pname}-${version}.tbz";
  };

  buildInputs = optional_buildInputs;
  buildPhase = "${topkg.run} build ${lib.escapeShellArgs enable_flags}";

  meta = {
    inherit (ocaml.meta) platforms;
    description = "Logging infrastructure for OCaml";
    homepage = webpage;
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ sternenseemann ];
  };
}
