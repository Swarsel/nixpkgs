{
  lib,
  fetchFromGitHub,
  _experimental-update-script-combinators,
  flutter338,
  gitUpdater,
  gst_all_1,
  libplacebo,
  libunwind,
  makeWrapper,
  mimalloc,
  mpv-unwrapped,
  nix,
  nix-prefetch-git,
  orc,
  pkg-config,
  python3,
  fletTarget ? "linux",
}:

flutter338.buildFlutterApplication rec {
  pname = "flet-client-flutter";
  version = "0.80.0";

  src = fetchFromGitHub {
    owner = "flet-dev";
    repo = "flet";
    tag = "v${version}";
    hash = "sha256-PxSFDWo5qN9RB/E+vLu1xYttJ8CQdy86OStyLMRn6Lo=";
  };

  nativeBuildInputs = [
    makeWrapper
    mimalloc
    pkg-config
  ];

  buildInputs = [
    mpv-unwrapped
    gst_all_1.gst-libav
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-bad
    gst_all_1.gstreamer
    libunwind
    orc
    mimalloc
  ]
  ++ mpv-unwrapped.buildInputs
  ++ libplacebo.buildInputs;

  cmakeFlags = [
    "-DMIMALLOC_LIB=${mimalloc}/lib/mimalloc.o"
  ];

  env.NIX_CFLAGS_COMPILE = toString [
    "-Wno-error=nontrivial-memcall"
  ];

  gitHashes = lib.importJSON ./git_hashes.json;
  pubspecLock = lib.importJSON ./pubspec.lock.json;
  sourceRoot = "${src.name}/client";
  targetFlutterPlatform = fletTarget;

  passthru = {
    updateScript = _experimental-update-script-combinators.sequence [
      (gitUpdater { rev-prefix = "v"; })
      {
        command = [
          "env"
          "PATH=${
            lib.makeBinPath [
              (python3.withPackages (p: [ p.pyyaml ]))
              nix-prefetch-git
              nix
            ]
          }"
          "python3"
          ./update-lockfiles.py
        ];

        supportedFeatures = [ "silent" ];
      }
    ];
  };

  meta = {
    description = "Framework that enables you to easily build realtime web, mobile, and desktop apps in Python. The frontend part";
    homepage = "https://flet.dev/";
    changelog = "https://github.com/flet-dev/flet/releases/tag/v${version}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      heyimnova
    ];

    mainProgram = "flet";
  };
}
