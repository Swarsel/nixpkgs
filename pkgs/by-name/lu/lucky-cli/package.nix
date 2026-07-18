{
  lib,
  fetchFromGitHub,
  crystal,
  makeWrapper,
  openssl,
}:

crystal.buildCrystalPackage rec {
  pname = "lucky-cli";
  version = "1.4.1";

  src = fetchFromGitHub {
    owner = "luckyframework";
    repo = "lucky_cli";
    tag = "v${version}";
    hash = "sha256-68As7PSRYwhJGcQwI4FgM9aN0nhNrEjcv+10jKnlXeA=";
  };

  # the integration tests will try to clone a remote repos
  postPatch = ''
    rm -rf spec/integration
  '';

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ openssl ];

  preConfigure = ''
    substituteInPlace "./src/lucky_cli/version.cr" \
      --replace-fail '`shards version #{__DIR__}`' '"${version}"'
  '';

  postInstall = ''
    wrapProgram $out/bin/lucky \
      --prefix PATH : ${lib.makeBinPath [ crystal ]}
  '';

  crystalBinaries.lucky.src = "src/lucky.cr";
  format = "crystal";
  lockFile = ./shard.lock;
  shardsFile = ./shards.nix;

  meta = {
    description = "Crystal library for creating and running tasks. Also generates Lucky projects";
    homepage = "https://luckyframework.org/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ peterhoeg ];
    platforms = lib.platforms.unix;
    mainProgram = "lucky";
    broken = lib.versionOlder crystal.version "1.6.0";
  };
}
