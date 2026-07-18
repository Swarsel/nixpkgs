{
  lib,
  fetchFromGitHub,
  buildDunePackage,
}:

buildDunePackage rec {
  pname = "timed";
  version = "1.1";

  src = fetchFromGitHub {
    owner = "rlepigre";
    repo = "ocaml-${pname}";
    rev = version;
    sha256 = "sha256-wUoI9j/j0IGYW2NfJHmyR2XEYfYejyoYLWnKsuWdFas=";
  };

  doCheck = true;
  minimalOCamlVersion = "4.08";

  meta = {
    description = "Timed references for imperative state";
    homepage = "https://github.com/rlepigre/ocaml-timed";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bcdarwin ];
  };
}
