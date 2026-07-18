{
  lib,
  stdenv,
  fetchFromGitHub,
  buildNpmPackage,
  ffmpeg-full,
  getopt,
  nixosTests,
  nodejs_22,
  nunicode,
  python3,
  runCommand,
  util-linux,
}:

let
  source = {
    version = "2.35.1";
    npmDepsHash = "sha256-wmbzbMQHrbHcL9JSpPXpc+vjjj5LTNN8e6Ug3ZRQ7mo=";
    clientNpmDepsHash = "sha256-wJdCvUVLZzCY3iW/Q7QVuRu96s49TehnuQNqbImbe0g=";
    hash = "sha256-31cKSjSTJyUetjCSOCDY2wnTFV+Z52LcvGrh7Emc0cM=";
  };

  src = fetchFromGitHub {
    inherit (source) hash;
    owner = "advplyr";
    repo = "audiobookshelf";
    tag = "v${source.version}";
  };

  client = buildNpmPackage {
    inherit (source) version;
    pname = "audiobookshelf-client";

    src = runCommand "cp-source" { } ''
      cp -r ${src}/client $out
    '';

    npmDepsHash = source.clientNpmDepsHash;
    # don't download the Cypress binary
    CYPRESS_INSTALL_BINARY = 0;
    NODE_OPTIONS = "--openssl-legacy-provider";
    nodejs = nodejs_22;
    npmBuildScript = "generate";
  };

  wrapper = import ./wrapper.nix {
    inherit
      stdenv
      ffmpeg-full
      nunicode
      getopt
      ;
  };

in
buildNpmPackage {
  inherit src;
  inherit (source) npmDepsHash version;
  pname = "audiobookshelf";
  nativeBuildInputs = [ python3 ];
  buildInputs = [ util-linux ];

  installPhase = ''
    mkdir -p $out/opt/client
    cp -r index.js server package* node_modules $out/opt/
    cp -r ${client}/lib/node_modules/audiobookshelf-client/dist $out/opt/client/dist
    mkdir $out/bin

    echo '${wrapper}' > $out/bin/audiobookshelf
    echo "  exec ${nodejs_22}/bin/node $out/opt/index.js" >> $out/bin/audiobookshelf

    chmod +x $out/bin/audiobookshelf
  '';

  dontNpmBuild = true;
  nodejs = nodejs_22;
  npmInstallFlags = [ "--only-production" ];

  passthru = {
    tests.basic = nixosTests.audiobookshelf;
    updateScript = ./update.sh;
  };

  meta = {
    description = "Self-hosted audiobook and podcast server";
    homepage = "https://www.audiobookshelf.org/";
    changelog = "https://github.com/advplyr/audiobookshelf/releases/tag/v${source.version}";
    license = lib.licenses.gpl3;

    maintainers = with lib.maintainers; [
      jvanbruegge
      adamcstephens
      tebriel
    ];

    platforms = lib.platforms.linux;
    mainProgram = "audiobookshelf";
  };
}
