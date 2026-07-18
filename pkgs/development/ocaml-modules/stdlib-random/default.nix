{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  cppo,
  version ? "1.2.0",
}:

buildDunePackage {
  inherit version;
  pname = "stdlib-random";

  src = fetchFromGitHub {
    owner = "ocaml";
    repo = "stdlib-random";
    tag = version;
    hash = "sha256-rtdPQ/zXdywjhjLi60nMe1rks2yLP2TH4xUg5z/Bpjk=";
  };

  nativeBuildInputs = [ cppo ];
  minimalOCamlVersion = "4.08";

  meta = {
    description = "Compatibility library for Random number generation";
    homepage = "https://github.com/ocaml/stdlib-random";
    license = lib.licenses.lgpl21Only;
    maintainers = [ lib.maintainers.vbgl ];
  };

}
