{
  lib,
  stdenv,
  fetchurl,
  alcotest,
  buildDunePackage,
  cacert,
  cohttp-lwt-unix,
  curl,
  ocaml,
  result,
}:

buildDunePackage (finalAttrs: {
  pname = "curly";
  version = "0.3.0";

  src = fetchurl {
    url = "https://github.com/rgrinberg/curly/releases/download/${finalAttrs.version}/curly-${finalAttrs.version}.tbz";
    hash = "sha256-Qn/PKBNOcMt3dk2f7uJD8x0yo4RHobXSjTQck7fcXTw=";
  };

  postPatch = ''
    substituteInPlace src/curly.ml \
      --replace "exe=\"curl\"" "exe=\"${curl}/bin/curl\""
    substituteInPlace test/test_curly.ml \
      --replace-fail "let body_header b = [\"content-length\", string_of_int (String.length b)]" \
                     "let body_header b = [\"connection\", \"keep-alive\"; \"content-length\", string_of_int (String.length b)]"
  '';

  propagatedBuildInputs = [ result ];

  # test dependencies are only available for >= 4.08
  # https://github.com/mirage/ca-certs/issues/16
  doCheck =
    lib.versionAtLeast ocaml.version "4.08"
    # Some test fails in macOS sandbox
    # > Fatal error: exception Unix.Unix_error(Unix.EPERM, "bind", "")
    && !stdenv.hostPlatform.isDarwin;

  nativeCheckInputs = [ cacert ];

  checkInputs = [
    alcotest
    cohttp-lwt-unix
  ];

  duneVersion = "3";
  minimalOCamlVersion = "4.03";

  meta = {
    description = "Curly is a brain dead wrapper around the curl command line utility";
    homepage = "https://github.com/rgrinberg/curly";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.sternenseemann ];
  };
})
