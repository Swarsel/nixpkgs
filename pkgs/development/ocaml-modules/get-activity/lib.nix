{
  lib,
  fetchFromGitHub,
  alcotest,
  astring,
  buildDunePackage,
  curly,
  fmt,
  logs,
  ppx_expect,
  ppx_yojson_conv,
  ppx_yojson_conv_lib,
  yojson,
}:

buildDunePackage (finalAttrs: {
  pname = "get-activity-lib";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "tarides";
    repo = "get-activity";
    rev = finalAttrs.version;
    hash = "sha256-QU/LPIxcem5nFvSxcNApOuBu6UHqLHIXVSOJ2UT0eKA=";
  };

  buildInputs = [ ppx_yojson_conv ];

  propagatedBuildInputs = [
    astring
    curly
    fmt
    logs
    ppx_yojson_conv_lib
    yojson
  ];

  doCheck = true;

  checkInputs = [
    ppx_expect
    alcotest
  ];

  minimalOCamlVersion = "4.08";

  meta = {
    description = "Collect activity and format as markdown for a journal (lib)";
    homepage = "https://github.com/tarides/get-activity";
    changelog = "https://github.com/tarides/get-activity/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ zazedd ];
  };
})
