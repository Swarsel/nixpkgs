{
  lib,
  stdenv,
  fetchFromGitHub,
  _experimental-update-script-combinators,
  crystal,
  crystal2nix,
  desktopToDarwinBundle,
  gitUpdater,
  gobject-introspection,
  libadwaita,
  libxml2,
  nautilus-python,
  openssl,
  pkg-config,
  python3,
  runCommand,
  wrapGAppsHook4,
  writeShellScript,
}:

crystal.buildCrystalPackage rec {
  pname = "Collision";
  version = "3.14.0";

  src = fetchFromGitHub {
    owner = "GeopJr";
    repo = "Collision";
    tag = "v${version}";
    hash = "sha256-GcCqItSHUhhS0yrOM8bMzkVsVHyC97c+yccw5ZP61IU=";
  };

  postPatch = ''
    substituteInPlace Makefile \
      --replace-fail 'gtk-update-icon-cache $(PREFIX)/share/icons/hicolor' 'true'
  '';

  # Crystal compiler has a strange issue with OpenSSL. The project will not compile due to
  # main_module:(.text+0x6f0): undefined reference to `SSL_library_init'
  # There is an explanation for this https://danilafe.com/blog/crystal_nix_revisited/
  # Shortly, adding pkg-config to buildInputs along with openssl fixes the issue.
  nativeBuildInputs = [
    wrapGAppsHook4
    pkg-config
    gobject-introspection
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    desktopToDarwinBundle
  ];

  buildInputs = [
    libadwaita
    openssl
    libxml2
    nautilus-python
    python3.pkgs.pygobject3
  ];

  preBuild = ''
    cd lib/gi-crystal && shards build -Dpreview_mt --release --no-debug && \
    install -Dm755 bin/gi-crystal ../../bin/gi-crystal && cd ../..
  '';

  doCheck = false;

  postInstall = ''
    install -Dm555 ./nautilus-extension/collision-extension.py -t $out/share/nautilus-python/extensions
  '';

  doInstallCheck = false;

  buildTargets = [
    "bindings"
    "build"
  ];

  copyShardDeps = true;

  installTargets = [
    "desktop"
    "install"
  ];

  shardsFile = ./shards.nix;

  passthru = {
    updateScript = _experimental-update-script-combinators.sequence [
      (gitUpdater { rev-prefix = "v"; })
      (_experimental-update-script-combinators.copyAttrOutputToFile "collision.shardLock" "./shard.lock")
      {
        command = [
          (writeShellScript "update-lock" "cd $1; ${lib.getExe crystal2nix}")
          ./.
        ];

        supportedFeatures = [ "silent" ];
      }
      {
        command = [
          "rm"
          "./shard.lock"
        ];

        supportedFeatures = [ "silent" ];
      }
    ];
  };

  meta = {
    description = "Check hashes for your files";
    homepage = "https://github.com/GeopJr/Collision";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ sund3RRR ];
    mainProgram = "collision";
    teams = [ lib.teams.gnome-circle ];
  };
}
