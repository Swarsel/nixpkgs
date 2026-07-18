{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  cmake,
  file, # for libmagic
  gperf,
  ncurses,
  nix-update-script,
  openssl,
  readline,
  replaceVars,
  sqlite,
  zlib,
  withWhatsApp ? true,
}:

let
  version = "5.16.9";

  src = fetchFromGitHub {
    owner = "d99kris";
    repo = "nchat";
    tag = "v${version}";
    hash = "sha256-Hl8LzROGn9oAV9G4hnnvDAltPte+2krEEGPNTmMzUoU=";
  };

  libcgowm = buildGoModule {
    inherit version src;
    pname = "nchat-wmchat-libcgowm";
    vendorHash = "sha256-t7WG9xce1UC5FB6LFIT7Oacc2rO/BqZ/p5JP0AtPDoo=";

    buildPhase = ''
      runHook preBuild

      mkdir -p $out/
      go build -o $out/ -buildmode=c-archive
      mv $out/go.a $out/libcgowm.a
      ln -s $out/libcgowm.a $out/libref-cgowm.a
      mv $out/go.h $out/libcgowm.h

      runHook postBuild
    '';

    sourceRoot = "${src.name}/lib/wmchat/go";
  };
in
stdenv.mkDerivation {
  inherit version src;
  pname = "nchat";

  patches = [
    (replaceVars ./go-libs-build.patch {
      inherit libcgowm;
    })
    # Don't use brew
    ./fix-darwin.patch
  ];

  nativeBuildInputs = [
    cmake
    gperf
    libcgowm
  ];

  buildInputs = [
    file # for libmagic
    ncurses
    openssl
    readline
    sqlite
    zlib
  ];

  cmakeFlags = [
    (lib.cmakeFeature "CMAKE_INSTALL_LIBDIR" "lib")
    (lib.cmakeBool "HAS_WHATSAPP" withWhatsApp)
  ];

  passthru = {
    inherit libcgowm;

    updateScript = nix-update-script {
      extraArgs = [
        "--subpackage"
        "libcgowm"
      ];
    };
  };

  meta = {
    description = "Terminal-based chat client with support for Telegram and WhatsApp";
    homepage = "https://github.com/d99kris/nchat";
    changelog = "https://github.com/d99kris/nchat/releases/tag/v${version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      luftmensch-luftmensch
      sikmir
    ];

    platforms = lib.platforms.unix;
    mainProgram = "nchat";
  };
}
