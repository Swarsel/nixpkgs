{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  buildPackages,
  fetchNpmDeps,
  fetchpatch,
  ffmpeg-headless,
  nix-update-script,
  nixosTests,
  nodejs_24,
  npmHooks,
  pkg-config,
  taglib,
  versionCheckHook,
  zlib,
  ffmpegSupport ? true,
  plugins ? [ ],
}:

buildGoModule (finalAttrs: {
  pname = "navidrome";
  version = "0.63.2";

  src = fetchFromGitHub {
    owner = "navidrome";
    repo = "navidrome";
    rev = "v${finalAttrs.version}";
    hash = "sha256-s0Pd6yT9NX2VFSPbLPX6Zqon8Y3qyDPGCKvqHPxcZ88=";
  };

  postPatch = ''
    patchShebangs ui/bin/update-workbox.sh
  '';

  nativeBuildInputs = [
    buildPackages.makeWrapper
    nodejs_24
    npmHooks.npmConfigHook
    pkg-config
  ];

  buildInputs = [
    taglib
    zlib
  ];

  vendorHash = "sha256-lNjOVrlRD6ptDBpmfGYCN3Vkal9ACciOyS1RANzKYK4=";

  env = lib.optionalAttrs stdenv.cc.isGNU {
    CGO_CFLAGS = toString [ "-Wno-return-local-addr" ];
  };

  preBuild = ''
    make buildjs
  '';

  postInstall = ''
    mkdir -p $out/share/plugins/
    ${lib.concatMapStringsSep "\n" (plugin: ''
      ln -s ${plugin}/share/${plugin.pname}.ndp $out/share/plugins/
    '') plugins}
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  postFixup = lib.optionalString ffmpegSupport ''
    wrapProgram $out/bin/navidrome \
      --prefix PATH : ${lib.makeBinPath [ ffmpeg-headless ]}
  '';

  excludedPackages = [
    "plugins"
  ];

  ldflags = [
    "-X github.com/navidrome/navidrome/consts.gitSha=${finalAttrs.src.rev}"
    "-X github.com/navidrome/navidrome/consts.gitTag=v${finalAttrs.version}"
  ];

  npmDeps = fetchNpmDeps {
    inherit (finalAttrs) src;
    hash = "sha256-uRF9cf6HZE0gyCvGTEZ520d2gMsxmccEYLJBgc47pMg=";
    sourceRoot = "${finalAttrs.src.name}/ui";
  };

  npmRoot = "ui";

  overrideModAttrs = oldAttrs: {
    nativeBuildInputs = lib.filter (drv: drv != npmHooks.npmConfigHook) oldAttrs.nativeBuildInputs;
    preBuild = null;
  };

  runtimeInputs = plugins;

  tags = [
    "netgo"
    "sqlite_fts5"
  ];

  passthru = {
    inherit plugins;
    tests.navidrome = nixosTests.navidrome;
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Music Server and Streamer compatible with Subsonic/Airsonic";
    homepage = "https://www.navidrome.org/";
    license = lib.licenses.gpl3Only;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];

    maintainers = with lib.maintainers; [
      aciceri
      tebriel
    ];

    mainProgram = "navidrome";
    # Broken on Darwin: sandbox-exec: pattern serialization length exceeds maximum (NixOS/nix#4119)
    broken = stdenv.hostPlatform.isDarwin;
  };
})
