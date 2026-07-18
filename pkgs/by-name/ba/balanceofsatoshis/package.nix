{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  python3,
}:

buildNpmPackage rec {
  pname = "balanceofsatoshis";
  version = "19.4.14";

  src = fetchFromGitHub {
    owner = "alexbosworth";
    repo = "balanceofsatoshis";
    tag = "v${version}";
    hash = "sha256-lXwE7/7ZWO6GD4SY0BPh/QXNpxkCYJS00Gjna0DkOE0=";
  };

  nativeBuildInputs = [ python3 ];
  npmDepsHash = "sha256-WKpbYzNd0srD8yVB7Xa4v4qF9qHBiHHtKrYitnqEPTM=";
  dontNpmBuild = true;
  npmFlags = [ "--ignore-scripts" ];

  meta = {
    description = "Tool for working with the balance of your satoshis on LND";
    homepage = "https://github.com/alexbosworth/balanceofsatoshis";
    changelog = "https://github.com/alexbosworth/balanceofsatoshis/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ mariaa144 ];
    mainProgram = "bos";
  };
}
