{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  camlp-streams,
  core_kernel,
  m4,
  ounit,
}:

buildDunePackage (finalAttrs: {
  pname = "cfstream";
  version = "1.3.2";

  src = fetchFromGitHub {
    owner = "biocaml";
    repo = "cfstream";
    rev = finalAttrs.version;
    hash = "sha256-iSg0QsTcU0MT/Cletl+hW6bKyH0jkp7Jixqu8H59UmQ=";
  };

  patches = [
    ./git_commit.patch
    ./janestreet-0.17.patch
  ];

  nativeBuildInputs = [ m4 ];

  propagatedBuildInputs = [
    camlp-streams
    core_kernel
  ];

  doCheck = true;
  checkInputs = [ ounit ];
  minimalOCamlVersion = "4.08";

  meta = {
    inherit (finalAttrs.src.meta) homepage;
    description = "Simple Core-inspired wrapper for standard library Stream module";
    license = lib.licenses.lgpl21;
    maintainers = [ lib.maintainers.bcdarwin ];
  };
})
