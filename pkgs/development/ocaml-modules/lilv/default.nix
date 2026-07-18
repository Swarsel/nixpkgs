{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  ctypes,
  ctypes-foreign,
  dune-configurator,
  lilv,
}:

buildDunePackage (finalAttrs: {
  pname = "lilv";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "savonet";
    repo = "ocaml-lilv";
    rev = "v${finalAttrs.version}";
    sha256 = "080ja8c4sxprk5qnldpfzxriag57m9603vny3b4bnwh5xm1id08c";
  };

  buildInputs = [ dune-configurator ];

  propagatedBuildInputs = [
    ctypes
    ctypes-foreign
    lilv
  ];

  minimalOCamlVersion = "4.03.0";

  meta = {
    description = "OCaml bindings for lilv";
    homepage = "https://github.com/savonet/ocaml-lilv";
    license = lib.licenses.lgpl21Only;
    maintainers = with lib.maintainers; [ dandellion ];
  };
})
