{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "joker";
  version = "1.5.8";

  src = fetchFromGitHub {
    owner = "candid82";
    repo = "joker";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-srBJiCqxNGfLZCxVHH6Mjs3Ht7Boy64qmPjr2+l/l1I=";
  };

  vendorHash = "sha256-yH8QVzliAFZlOvprfdh/ClCWK2/7F96f0yLWvuAhGY8=";

  preBuild = ''
    go generate ./...
  '';

  doCheck = false;
  subPackages = [ "." ];

  meta = {
    description = "Small Clojure interpreter and linter written in Go";
    homepage = "https://github.com/candid82/joker";
    license = lib.licenses.epl10;
    maintainers = with lib.maintainers; [ andrestylianos ];
    mainProgram = "joker";
  };
})
