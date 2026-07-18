{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  makeBinaryWrapper,
  nix-update-script,
  nodejs,
}:

buildNpmPackage {
  pname = "jsonplaceholder";
  version = "0.3.3-unstable-2021-06-14";

  src = fetchFromGitHub {
    owner = "typicode";
    repo = "jsonplaceholder";
    rev = "7ae4432ac3f60e7226a899c25e04826207d07098";
    hash = "sha256-b+p1bByq0oRj3zqVsFFoXFR2ydrbZqWwJdVIaXEmQwQ=";
  };

  nativeBuildInputs = [ makeBinaryWrapper ];
  npmDepsHash = "sha256-x+EN33CQE4ga9T0V4oJRPkELT8x4WbNIsQmvyW+hHi8=";

  postInstall = ''
    rm -rf $out/lib/node_modules/jsonplaceholder/node_modules/.bin

    makeWrapper ${nodejs}/bin/node $out/bin/jsonplaceholder \
      --add-flags $out/lib/node_modules/jsonplaceholder/index.js \
      --set NODE_PATH "$out/lib/node_modules"
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Simple online fake REST API server";
    homepage = "https://jsonplaceholder.typicode.com/";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
