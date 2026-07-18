{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  core_kernel,
  cstruct-unix,
  ppx_cstruct,
  rresult,
}:

buildDunePackage (finalAttrs: {
  pname = "dbf";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "pveber";
    repo = "dbf";
    rev = "v${finalAttrs.version}";
    hash = "sha256-096GodM3J/4dsVdylG+6xz/p6ogUkhDGdFjiPwl/jLQ=";
  };

  buildInputs = [ ppx_cstruct ];

  propagatedBuildInputs = [
    rresult
    cstruct-unix
    core_kernel
  ];

  duneVersion = "3";
  minimalOCamlVersion = "4.08";

  meta = {
    description = "DBF format parsing";
    homepage = "https://github.com/pveber/dbf";
    license = lib.licenses.isc;
    maintainers = [ lib.maintainers.deltadelta ];
  };
})
