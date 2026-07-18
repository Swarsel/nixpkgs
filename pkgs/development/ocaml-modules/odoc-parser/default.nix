{
  lib,
  fetchurl,
  astring,
  buildDunePackage,
  camlp-streams,
  ocaml,
  result,
  version ? "3.2.1",
}:

let
  param =
    {
      "0.9.0" = {
        max_version = "5.0";
        sha256 = "sha256-3w2tG605v03mvmZsS2O5c71y66O3W+n3JjFxIbXwvXk=";
      };

      "1.0.0" = {
        max_version = "5.0";
        sha256 = "sha256-tqoI6nGp662bK+vE2h7aDXE882dObVfRBFnZNChueqE=";
      };

      "1.0.1" = {
        sha256 = "sha256-orvo5CAbYOmAurAeluQfK6CwW6P1C0T3WDfoovuQfSw=";
      };

      "2.0.0" = {
        sha256 = "sha256-QHkZ+7DrlXYdb8bsZ3dijZSqGQc0O9ymeLGIC6+zOSI=";
      };

      "2.4.4" = {
        sha256 = "sha256-fiU6VbXI9hD54LSJQOza8hwBVTFDr5O0DJmMMEmeUfM=";
      };

      "3.1.0" = {
        sha256 = "sha256-NVs8//STSQPLrti1HONeMz6GCZMtIwKUIAqfLUL/qRQ=";
      };

      "3.2.1" = {
        sha256 = "sha256-1F6xJVFIOf2awncCu0k40bTztpeOmxarlnPqBnJFr/w=";
      };
    }
    ."${version}";
in

lib.throwIf (param ? max_version && lib.versionAtLeast ocaml.version param.max_version)
  "odoc-parser ${version} is not available for OCaml ${ocaml.version}"

  buildDunePackage
  rec {
    inherit version;
    pname = "odoc-parser";

    src = fetchurl {
      inherit (param) sha256;

      url =
        if lib.versionAtLeast version "2.4" then
          "https://github.com/ocaml/odoc/releases/download/${version}/odoc-${version}.tbz"
        else
          "https://github.com/ocaml-doc/odoc-parser/releases/download/${version}/odoc-parser-${version}.tbz";
    };

    propagatedBuildInputs = [
      astring
    ]
    ++ lib.optional (!lib.versionAtLeast version "3.1.0") result
    ++ lib.optional (lib.versionAtLeast version "1.0.1") camlp-streams;

    meta = {
      description = "Parser for Ocaml documentation comments";
      homepage = "https://github.com/ocaml-doc/odoc-parser";
      changelog = "https://github.com/ocaml-doc/odoc-parser/raw/${version}/CHANGES.md";
      license = lib.licenses.isc;
      maintainers = [ ];
    };
  }
