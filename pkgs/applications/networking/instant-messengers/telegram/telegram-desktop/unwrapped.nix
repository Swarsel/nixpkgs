{
  lib,
  stdenv,
  fetchFromGitHub,
  ada,
  apple-sdk_15,
  boost,
  callPackage,
  clang,
  cmake,
  ffmpeg_6,
  gobject-introspection,
  hunspell,
  kcoreaddons,
  libavif,
  libheif,
  libicns,
  libjxl,
  llvmPackages,
  lz4,
  microsoft-gsl,
  minizip-ng-compat,
  ninja,
  nix-update-script,
  openal-soft,
  pkg-config,
  protobuf,
  python3,
  qtbase,
  qtshadertools,
  qtsvg,
  qtwayland,
  range-v3,
  rnnoise,
  tdlib,
  tl-expected,
  xxhash,
  tg_owt ? callPackage ./tg_owt.nix { inherit stdenv; },
}:

# Main reference:
# - This package was originally based on the Arch package but all patches are now upstreamed:
#   https://git.archlinux.org/svntogit/community.git/tree/trunk/PKGBUILD?h=packages/telegram-desktop
# Other references that could be useful:
# - https://git.alpinelinux.org/aports/tree/testing/telegram-desktop/APKBUILD
# - https://github.com/void-linux/void-packages/blob/master/srcpkgs/telegram-desktop/template

stdenv.mkDerivation (finalAttrs: {
  pname = "telegram-desktop-unwrapped";
  version = "6.9.3";

  src = fetchFromGitHub {
    owner = "telegramdesktop";
    repo = "tdesktop";
    rev = "v${finalAttrs.version}";
    hash = "sha256-QCGtESg+38lHWCFcsevHdc0kQ7LKJQmJjUJWszphah8=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    pkg-config
    cmake
    ninja
    python3
    qtshadertools
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    # to build bundled libdispatch
    clang
    gobject-introspection
  ]
  # Work around ld64's libc++ hardening issue causing Trace/BPT trap: 5
  # TODO: Remove once nixpkgs#536365 reaches this branch.
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    llvmPackages.lld
  ];

  buildInputs = [
    qtbase
    qtsvg
    lz4
    xxhash
    ffmpeg_6
    openal-soft
    minizip-ng-compat
    range-v3
    tl-expected
    rnnoise
    tg_owt
    microsoft-gsl
    boost
    ada
    (tdlib.override { tde2eOnly = true; })
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    protobuf
    qtwayland
    kcoreaddons
    hunspell
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    apple-sdk_15
    libicns
    libavif
    libheif
    libjxl
  ];

  cmakeFlags = [
    # We're allowed to used the API ID of the Snap package:
    (lib.cmakeFeature "TDESKTOP_API_ID" "611335")
    (lib.cmakeFeature "TDESKTOP_API_HASH" "d524b414d21f4d37f08684c1df41ac9c")
    # swift 6 is not available in nixpkgs
    (lib.cmakeBool "DESKTOP_APP_DISABLE_SWIFT6" true)
  ];

  # Work around ld64's libc++ hardening issue causing Trace/BPT trap: 5
  # TODO: Remove once nixpkgs#536365 reaches this branch.
  env = lib.optionalAttrs stdenv.hostPlatform.isDarwin {
    NIX_CFLAGS_LINK = "-fuse-ld=lld";
  };

  installPhase = lib.optionalString stdenv.hostPlatform.isDarwin ''
    runHook preInstall

    mkdir -p $out/Applications
    cp -r ${finalAttrs.meta.mainProgram}.app $out/Applications
    ln -sr $out/{Applications/${finalAttrs.meta.mainProgram}.app/Contents/MacOS,bin}

    runHook postInstall
  '';

  dontWrapQtApps = true;

  passthru = {
    inherit tg_owt;
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Telegram Desktop messaging app";

    longDescription = ''
      Desktop client for the Telegram messenger, based on the Telegram API and
      the MTProto secure protocol.
    '';

    homepage = "https://desktop.telegram.org/";
    changelog = "https://github.com/telegramdesktop/tdesktop/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ nickcao ];
    platforms = lib.platforms.all;
    mainProgram = "Telegram";
  };
})
