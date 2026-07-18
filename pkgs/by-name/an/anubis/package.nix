{
  lib,
  stdenv,
  fetchFromGitHub,
  brotli,
  buildGoModule,
  esbuild,
  fetchNpmDeps,
  nix-update-script,
  nixosTests,
  nodejs,
  npmHooks,
  zstd,
}:

buildGoModule (finalAttrs: {
  pname = "anubis";
  version = "1.25.0";

  src = fetchFromGitHub {
    owner = "TecharoHQ";
    repo = "anubis";
    tag = "v${finalAttrs.version}";
    hash = "sha256-9/XIwSMEmnS3L/Wzg6ABso7R6W3TYkJomC8aFMycxZo=";
  };

  postPatch = ''
    patchShebangs ./web/build.sh ./lib/challenge/preact/build.sh
  '';

  nativeBuildInputs = [
    esbuild
    brotli
    zstd

    nodejs
    npmHooks.npmConfigHook
  ];

  vendorHash = "sha256-9CMD8Rn4q8b+hyrph+BqqS32ijZyJRNsop6ML7z5Zuk=";

  preBuild = ''
    # do not run when creating go vendor archive
    if [[ ! $name =~ go-modules ]]; then
      # https://github.com/TecharoHQ/anubis/blob/main/xess/build.sh
      npx postcss ./xess/xess.css -o xess/xess.min.css
      go generate ./...
      ./web/build.sh
    fi
  '';

  preCheck = ''
    export DONT_USE_NETWORK=1
  '';

  ldflags = [
    "-s"
    "-w"
    "-X=github.com/TecharoHQ/anubis.Version=v${finalAttrs.version}"
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ "-extldflags=-static" ];

  npmDeps = fetchNpmDeps {
    inherit (finalAttrs) src;
    hash = "sha256-2U91Dt+ymspjYgTtgCjahCNr6fIs85TT/k+I8M2aC9s=";
    name = "anubis-npm-deps";
  };

  prePatch = ''
    # we must forcefully disable the hook when creating the go vendor archive
    if [[ $name =~ go-modules ]]; then
      npmConfigHook() { true; }
    fi
  '';

  subPackages = [ "cmd/anubis" ];

  passthru = {
    tests = { inherit (nixosTests) anubis; };
    updateScript = nix-update-script { extraArgs = [ "--version-regex=^v(\\d+\\.\\d+\\.\\d+)$" ]; };
  };

  meta = {
    description = "Weighs the soul of incoming HTTP requests using proof-of-work to stop AI crawlers";
    homepage = "https://anubis.techaro.lol/";
    changelog = "https://github.com/TecharoHQ/anubis/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      knightpp
      soopyc
      ryand56
      defelo
    ];

    mainProgram = "anubis";
    downloadPage = "https://github.com/TecharoHQ/anubis";
  };
})
