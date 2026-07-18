{
  lib,
  stdenv,
  fetchFromGitHub,
  buildNpmPackage,
  nodejs,
}:

buildNpmPackage rec {
  inherit nodejs;
  pname = "node-gyp";
  version = "13.0.1";

  src = fetchFromGitHub {
    owner = "nodejs";
    repo = "node-gyp";
    tag = "v${version}";
    hash = "sha256-AoHPkoyWxpnDjCVKVVab+ml+2DF47NfmTK3mk24rMCQ=";
  };

  postPatch = ''
    ln -s ${./package-lock.json} package-lock.json
    substituteInPlace gyp/pylib/gyp/**.py \
      --replace-quiet sys.platform '"${stdenv.targetPlatform.parsed.kernel.name}"'
  '';

  npmDepsHash = "sha256-udF/exHe0Gy6JLrXP/47PKV5njEHRImYg0kDlHQoJbs=";
  dontNpmBuild = true;
  # Teach node-gyp to use nodejs headers locally rather that download them form https://nodejs.org.
  # This is important when build nodejs packages in sandbox.
  makeWrapperArgs = [ "--set npm_config_nodedir ${nodejs}" ];
  passthru.updateScript = ./update.sh;

  meta = {
    description = "Node.js native addon build tool";
    homepage = "https://github.com/nodejs/node-gyp";
    changelog = "https://github.com/nodejs/node-gyp/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
    mainProgram = "node-gyp";
  };
}
