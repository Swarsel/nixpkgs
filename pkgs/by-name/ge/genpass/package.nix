{
  lib,
  fetchgit,
  rustPlatform,
  zlib,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "genpass";
  version = "0.5.1";

  src = fetchgit {
    url = "https://git.sr.ht/~cyplo/genpass";
    rev = "v${finalAttrs.version}";
    sha256 = "UyEgOlKtDyneRteN3jHA2BJlu5U1HFL8HA2MTQz5rns=";
  };

  buildInputs = [
    zlib
  ];

  cargoHash = "sha256-tcE2TugvTJyUsgkxff31U/PIiO1IMr4rO6FKYP/oEiw=";

  meta = {
    description = "Simple yet robust commandline random password generator";
    homepage = "https://sr.ht/~cyplo/genpass/";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ cyplo ];
    mainProgram = "genpass";
  };
})
