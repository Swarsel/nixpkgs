{
  lib,
  stdenv,
  fetchFromGitLab,
  asciidoc,
  # makepkg requires compgen to work
  bashInteractive,
  binutils,
  bzip2,
  coreutils,
  curl,
  # pacman-key runtime dependencies
  gawk,
  gettext,
  gnugrep,
  gnupg,
  gpgme,
  # Compression tools in scripts/libmakepkg/util/compress.sh.in
  gzip,
  installShellFiles,
  libarchive,
  lrzip,
  lz4,
  lzip,
  lzop,
  makeWrapper,
  meson,
  ncompress,
  ninja,
  openssl,
  perl,
  pkg-config,
  xz,
  zlib,
  zstd,
  # Tells pacman where to find ALPM hooks provided by packages.
  # This path is very likely to be used in an Arch-like root.
  sysHookDir ? "/usr/share/libalpm/hooks/",
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pacman";
  version = "7.1.0-unstable-2026-01-25";

  src = fetchFromGitLab {
    owner = "pacman";
    repo = "pacman";
    rev = "cb7452f63414291b52061166ab2ebf1083897917";
    hash = "sha256-ocynGQ1oIeaQgLlCTCrxq/ihxziDMqrIPKAJThvV7SE=";
    domain = "gitlab.archlinux.org";
  };

  patches = [
    ./dont-create-empty-dirs.patch
  ];

  postPatch =
    let
      compressionTools = [
        gzip
        bzip2
        xz
        zstd
        lrzip
        lzop
        ncompress
        lz4
        lzip
      ];
    in
    ''
      echo 'export PATH=${lib.makeBinPath compressionTools}:$PATH' >> scripts/libmakepkg/util/compress.sh.in
      substituteInPlace meson.build \
        --replace-fail "install_dir : SYSCONFDIR" "install_dir : '$out/etc'" \
        --replace-fail "join_paths(DATAROOTDIR, 'libalpm/hooks/')" "'${sysHookDir}'" \
        --replace-fail "join_paths(SYSCONFDIR, 'makepkg.conf.d/')" "'$out/etc/makepkg.conf.d/'"
      substituteInPlace doc/meson.build \
        --replace-fail "/bin/true" "${coreutils}/bin/true"
      substituteInPlace scripts/repo-add.sh.in \
        --replace-fail bsdtar "${libarchive}/bin/bsdtar"
    '';

  strictDeps = true;

  nativeBuildInputs = [
    asciidoc
    bashInteractive
    gettext
    installShellFiles
    libarchive
    makeWrapper
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    curl
    gpgme
    libarchive
    openssl
    perl
    zlib
  ];

  mesonFlags = [
    "--sysconfdir=/etc"
    "--localstatedir=/var"
  ];

  postInstall = ''
    installShellCompletion --bash scripts/pacman --zsh scripts/_pacman
    wrapProgram $out/bin/makepkg \
      --prefix PATH : ${lib.makeBinPath [ binutils ]}
    wrapProgram $out/bin/pacman-key \
      --prefix PATH : ${
        lib.makeBinPath [
          "${placeholder "out"}"
          coreutils
          gawk
          gettext
          gnugrep
          gnupg
        ]
      }
  '';

  meta = {
    description = "Simple library-based package manager";
    homepage = "https://archlinux.org/pacman/";
    changelog = "https://gitlab.archlinux.org/pacman/pacman/-/raw/v${finalAttrs.version}/NEWS";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ samlukeyes123 ];
    platforms = lib.platforms.linux;
    mainProgram = "pacman";
  };
})
