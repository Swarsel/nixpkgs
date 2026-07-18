{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
}:

buildNpmPackage rec {
  pname = "write-good";
  version = "1.0.8";

  src = fetchFromGitHub {
    owner = "btford";
    repo = "write-good";
    rev = "v${version}";
    hash = "sha256-cq3cj2BwoQMKqo3iU2l+PR/2bJIFMSTRsDGQJ06GWXk=";
  };

  npmDepsHash = "sha256-0M9RzyeINmUPYcLy654iI+/ehElKrhIAibpiSqlXD2A=";

  postInstall = ''
    # Remove the .bin directory as it contains broken symlinks
    rm -rf $out/lib/node_modules/write-good/node_modules/.bin
  '';

  dontNpmBuild = true;

  meta = {
    description = "Naive linter for English prose";
    homepage = "https://github.com/btford/write-good";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "write-good";
  };
}
