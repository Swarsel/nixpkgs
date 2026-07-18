{
  lib,
  fetchurl,
  fetchFromGitHub,
  buildDunePackage,
  ocaml,
  ocaml-compiler-libs,
  ocaml-migrate-parsetree,
  ocaml-migrate-parsetree-2,
  ppx_derivers,
  stdio,
  stdlib-shims,
  version ?
    if lib.versionAtLeast ocaml.version "4.07" then
      if lib.versionAtLeast ocaml.version "4.08" then
        if lib.versionAtLeast ocaml.version "4.11" then
          if lib.versionAtLeast ocaml.version "5.03" then
            if lib.versionAtLeast ocaml.version "5.04" then "0.38.0" else "0.36.2"
          else
            "0.34.0"
        else
          "0.24.0"
      else
        "0.15.0"
    else
      "0.13.0",
}:

let
  param =
    {
      "0.13.0" = {
        OMP = [ ocaml-migrate-parsetree ];
        max_version = "4.11";
        min_version = "4.07";
        sha256 = "sha256-geHz0whQDg5/YQjVsN2iuHlkClwh7z3Eqb2QOBzuOdk=";
      };

      "0.15.0" = {
        OMP = [ ocaml-migrate-parsetree ];
        max_version = "4.12";
        min_version = "4.07";
        sha256 = "sha256-C2MNf410qJmlXMJxiLXOA+c1qT8H6gwt5WUy2P2TszA=";
      };

      "0.18.0" = {
        OMP = [ ocaml-migrate-parsetree-2 ];
        max_version = "4.12";
        min_version = "4.07";
        sha256 = "sha256-nUg8NkZ64GHHDfcWbtFGXq3MNEKu+nYPtcVDm/gEfcM=";
      };

      "0.22.0" = {
        OMP = [ ocaml-migrate-parsetree-2 ];
        max_version = "4.13";
        min_version = "4.07";
        sha256 = "sha256-PuuR4DlmZiKEoyIuYS3uf0+it2N8U9lXLSp0E0u5bXo=";
      };

      "0.22.2" = {
        OMP = [ ocaml-migrate-parsetree-2 ];
        max_version = "4.14";
        min_version = "4.07";
        sha256 = "sha256-0Oih69xiILFXTXqSbwCEYMURjM73m/mgzgJC80z/Ilo=";
      };

      "0.23.0" = {
        max_version = "4.14";
        min_version = "4.07";
        sha256 = "sha256-G1g2wYa51aFqz0falPOWj08ItRm3cpzYao/TmXH+EuU=";
      };

      "0.24.0" = {
        max_version = "5.1";
        min_version = "4.07";
        sha256 = "sha256-d2YCfC7ND1s7Rg6SEqcHCcZ0QngRPrkfMXxWxB56kMg=";
      };

      "0.28.0" = {
        max_version = "5.1";
        min_version = "4.07";
        sha256 = "sha256-2Hrl+aCBIGMIypZICbUKZq646D0lSAHouWdUSLYM83c=";
      };

      "0.30.0" = {
        min_version = "4.07";
        sha256 = "sha256-3UpjvenSm0mBDgTXZTk3yTLxd6lByg4ZgratU6xEIRA=";
      };

      "0.32.1" = {
        min_version = "4.07";
        sha256 = "sha256-nbrYvLHItPPfP1i8pgpe0j2GUx8No0tBlshr1YXAnX8=";
      };

      "0.33.0" = {
        min_version = "4.07";
        sha256 = "sha256-/6RO9VHyO3XiHb1pijAxBDE4Gq8UC5/kuBwucKLSxjo=";
      };

      "0.34.0" = {
        sha256 = "sha256-132XFloVjXrla3wDh80E6ZJ9fn55fKEDn/tbsXpmYac=";
      };

      "0.36.2" = {
        min_version = "4.08";
        sha256 = "sha256-yHVgB9jKwTeahGEUYQDB1hHH327MGpoKqb3ewNbk5xs=";
      };

      "0.37.0" = {
        max_version = "5.5";
        sha256 = "sha256-LiI4N+fOzDvISkMkMsCnL04dW+kWXJwzdy8VbbhdsLM=";
      };

      "0.38.0" = {
        sha256 = "sha256-ieBJsxAvZnCiE9NNgC6jqw/FMKiVnS8aHo24MAY0KaM=";
      };

      "0.8.1" = {
        OMP = [ ocaml-migrate-parsetree ];
        max_version = "4.10";
        sha256 = "sha256-pct57oO7qAMEtlvEfymFOCvviWaLG0b5/7NzTC8vdSE=";
      };
    }
    ."${version}";
in

buildDunePackage (finalAttrs: {
  inherit version;
  pname = "ppxlib";

  src = fetchurl {
    inherit (param) sha256;
    url = "https://github.com/ocaml-ppx/ppxlib/releases/download/${finalAttrs.version}/ppxlib-${finalAttrs.version}.tbz";
  };

  propagatedBuildInputs = [
    ocaml-compiler-libs
  ]
  ++ (param.OMP or [ ])
  ++ [
    ppx_derivers
    stdio
    stdlib-shims
  ];

  meta = {
    description = "Comprehensive ppx tool set";
    homepage = "https://github.com/ocaml-ppx/ppxlib";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.vbgl ];

    broken =
      param ? max_version && lib.versionAtLeast ocaml.version param.max_version
      || param ? min_version && lib.versionOlder ocaml.version param.min_version;
  };
})
