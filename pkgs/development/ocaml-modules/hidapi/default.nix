{
  lib,
  fetchFromGitHub,
  bigstring,
  buildDunePackage,
  dune-configurator,
  pkg-config,
  pkgs,
}:

buildDunePackage (finalAttrs: {
  pname = "hidapi";
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "vbmithr";
    repo = "ocaml-hidapi";
    rev = finalAttrs.version;
    hash = "sha256-upygm5G46C65lxaiI6kBOzLrWxzW9qWb6efN/t58SRg=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    pkgs.hidapi
    dune-configurator
  ];

  propagatedBuildInputs = [ bigstring ];
  doCheck = true;
  duneVersion = "3";
  minimalOCamlVersion = "4.03";

  meta = {
    description = "Bindings to Signal11's hidapi library";
    homepage = "https://github.com/vbmithr/ocaml-hidapi";
    license = lib.licenses.isc;
    maintainers = [ ];
    mainProgram = "ocaml-hid-enumerate";
  };
})
