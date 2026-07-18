{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cairo,
  fetchNpmDeps,
  giflib,
  hatchling,
  nodejs,
  npmHooks,
  pango,
  pixman,
  pkg-config,
  yt-dlp,
}:

buildPythonPackage rec {
  pname = "bgutil-ytdlp-pot-provider";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "Brainicism";
    repo = "bgutil-ytdlp-pot-provider";
    tag = version;
    hash = "sha256-dhpataQ1HSCRPnm4k3K/NMaQPQdNrx8C4q855l7kbbQ=";
  };

  nativeBuildInputs = [
    nodejs
    npmHooks.npmConfigHook
    pkg-config
  ];

  buildInputs = [
    cairo
    giflib
    pango
    pixman
  ];

  preBuild = ''
    cd server
    npx tsc
    npm prune --omit=dev
    cd ../plugin
  '';

  doCheck = false; # no tests

  postInstall = ''
    cd ..

    mkdir -p $out/share/bgutil-ytdlp-pot-provider/
    cp -r server/{build,node_modules} $out/share/bgutil-ytdlp-pot-provider/
    makeWrapper ${lib.getExe nodejs} $out/bin/bgutil-ytdlp-pot-provider \
      --add-flags $out/share/bgutil-ytdlp-pot-provider/build/main.js

    cd plugin
  '';

  build-system = [ hatchling ];
  dependencies = [ yt-dlp ];

  npmDeps = fetchNpmDeps {
    src = src + "/server";
    hash = "sha256-Qwwi6W+Oeu6ZeLmZP5vEfAKOJyivbULR5mlk7tcVIE8=";
    name = "${pname}-${version}-npm-deps";
    npmDepsFetcherVersion = 2;
  };

  npmRoot = "server";
  pyproject = true;

  meta = {
    description = "Proof-of-origin token provider plugin for yt-dlp";
    homepage = "https://github.com/Brainicism/bgutil-ytdlp-pot-provider";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ hexa ];
    mainProgram = "bgutil-ytdlp-pot-provider";
  };
}
