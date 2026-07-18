{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
}:

buildNpmPackage rec {
  pname = "elm-test";
  version = "0.19.1-revision17";

  src = fetchFromGitHub {
    owner = "rtfeldman";
    repo = "node-test-runner";
    rev = version;
    hash = "sha256-qmzmImTDH7CBFxEDtR+XydegnpuYiZuNF6eJ80I2fwM=";
  };

  postPatch = ''
    sed -i '/elm-tooling install/d' package.json
  '';

  npmDepsHash = "sha256-Yy53mGzARXRnPDLWnUevbnSCMSch1ecsvROu5C96WBA=";

  postInstall = ''
    # clean up broken symlinks to build tool binaries
    find $out/lib/node_modules/elm-test/node_modules/.bin \
      -xtype l \
      -delete
  '';

  dontNpmBuild = true;

  meta = {
    description = "Runs elm-test suites from Node.js";
    homepage = "https://github.com/rtfeldman/node-test-runner";
    changelog = "https://github.com/rtfeldman/node-test-runner/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ turbomack ];
    mainProgram = "elm-test";
  };
}
