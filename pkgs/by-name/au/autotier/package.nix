{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  fetchpatch,
  fuse3,
  installShellFiles,
  lib45d,
  liburing,
  onetbb,
  pkg-config,
  rocksdb,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "autotier";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "45Drives";
    repo = "autotier";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Pf1baDJsyt0ScASWrrgMu8+X5eZPGJSu0/LDQNHe1Ok=";
  };

  patches = [
    # https://github.com/45Drives/autotier/pull/70
    # fix "error: 'uintmax_t' has not been declared" build failure until next release
    (fetchpatch {
      hash = "sha256-0ab8YBgdJMxBHfOgUsgPpyUE1GyhAU3+WCYjYA2pjqo=";
      url = "https://github.com/45Drives/autotier/commit/d447929dc4262f607d87cbc8ad40a54d64f5011a.patch";
    })
    # Unvendor rocksdb (nixpkgs already applies RTTI and PORTABLE flags) and use pkg-config for flags
    (fetchpatch {
      hash = "sha256-+W3RwSe8zJKgZIXOaawHuI6xRzedYIcZundPC8eHuwM=";
      url = "https://github.com/45Drives/autotier/commit/fa282f5079ff17c144a7303d64dad0e44681b87f.patch";
    })
    # Add missing list import to src/incl/config.hpp
    (fetchpatch {
      hash = "sha256-3+KOh7JvbujCMbMqnZ5SGopAuOKHitKq6XV6a/jkcog=";
      url = "https://github.com/45Drives/autotier/commit/1f97703f4dfbfe093f5c18c4ee01dcc1c8fe04f3.patch";
    })
  ];

  postPatch = ''
    # Fix build with boost 1.89+ where boost_system stub library has been removed
    substituteInPlace makefile --replace-fail "-lboost_system" ""
  '';

  nativeBuildInputs = [
    pkg-config
    installShellFiles
  ];

  buildInputs = [
    rocksdb
    boost
    fuse3
    lib45d
    onetbb
    liburing
  ];

  # Required by rocksdb after 10.7.5
  env.EXTRA_CFLAGS = "-std=c++20 -fno-char8_t";

  installPhase = ''
    runHook preInstall

    # binaries
    installBin dist/from_source/*

    # docs
    installManPage doc/man/autotier.8

    # Completions
    installShellCompletion --bash doc/completion/autotier.bash-completion
    installShellCompletion --bash doc/completion/autotierfs.bash-completion

    # Scripts
    installBin script/autotier-init-dirs

    # Default config
    install -Dm755 -t $out/etc/autotier.conf doc/autotier.conf.template

    runHook postInstall
  '';

  meta = {
    description = "Passthrough FUSE filesystem that intelligently moves files between storage tiers based on frequency of use, file age, and tier fullness";
    homepage = "https://github.com/45Drives/autotier";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ jadewilk ];
    platforms = lib.platforms.linux; # uses io_uring so only available on linux not unix
    mainProgram = "autotier"; # cli, for file system use autotierfs
  };
})
