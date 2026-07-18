{
  lib,
  fetchurl,
  angstrom-lwt-unix,
  buildDunePackage,
  logs,
  lwt,
  lwt_ppx,
  ppx_deriving_yojson,
  ppx_expect,
  ppx_here,
  react,
}:

buildDunePackage (finalAttrs: {
  pname = "dap";
  version = "1.0.6";

  src = fetchurl {
    url = "https://github.com/hackwaly/ocaml-dap/releases/download/${finalAttrs.version}/dap-${finalAttrs.version}.tbz";
    sha256 = "1zq0f8429m38a4x3h9n3rv7n1vsfjbs72pfi5902a89qwyilkcp0";
  };

  buildInputs = [
    lwt_ppx
  ];

  propagatedBuildInputs = [
    angstrom-lwt-unix
    logs
    lwt
    ppx_deriving_yojson
    ppx_expect
    ppx_here
    react
  ];

  duneVersion = "3";
  minimalOCamlVersion = "4.08";

  meta = {
    description = "Debug adapter protocol";
    homepage = "https://github.com/hackwaly/ocaml-dap";
    license = lib.licenses.mit;
  };
})
