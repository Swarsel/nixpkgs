{
  lib,
  stdenv,
  fetchFromGitLab,
  autoconf,
  automake,
  buildPackages,
  flex,
  gdbm,
  gettext,
  gnulib,
  groff,
  gzip,
  libiconv,
  libiconvReal,
  libpipeline,
  libtool,
  makeWrapper,
  nix-update-script,
  nixosTests,
  pkg-config,
  util-linuxMinimal,
  zstd,
}:

let
  libiconv' =
    if stdenv.hostPlatform.isDarwin || stdenv.hostPlatform.isFreeBSD then libiconvReal else libiconv;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "man-db";
  version = "2.13.1";

  src = fetchFromGitLab {
    owner = "man-db";
    repo = "man-db";
    tag = finalAttrs.version;
    hash = "sha256-o85IJCsP5NA4AUhr6SNLOSnAoIEWoEejVG8w08jfyqQ=";
  };

  outputs = [
    "out"
    "doc"
  ];

  patches = [
    ./systemwide-man-db-conf.patch
  ];

  postPatch = ''
    # Remove all mandatory manpaths. Nixpkgs makes no requirements on
    # these directories existing.
    sed -i 's/^MANDATORY_MANPATH/# &/' src/man_db.conf.in

    # Add Nix-related manpaths
    echo "MANPATH_MAP	/nix/var/nix/profiles/default/bin	/nix/var/nix/profiles/default/share/man" >> src/man_db.conf.in

    # Add mandb locations for the above
    echo "MANDB_MAP	/nix/var/nix/profiles/default/share/man	/var/cache/man/nixpkgs" >> src/man_db.conf.in
  '';

  strictDeps = true;

  nativeBuildInputs = [
    autoconf
    automake
    flex
    gettext
    groff
    libtool
    makeWrapper
    pkg-config
    zstd
  ];

  buildInputs = [
    libpipeline
    gdbm
    groff
    libiconv'
  ]; # (Yes, 'groff' is both native and build input)

  configureFlags = [
    "--disable-setuid"
    "--disable-cache-owner"
    "--localstatedir=/var"
    "--with-config-file=${placeholder "out"}/etc/man_db.conf"
    "--with-systemdtmpfilesdir=${placeholder "out"}/lib/tmpfiles.d"
    "--with-systemdsystemunitdir=${placeholder "out"}/lib/systemd/system"
    "--with-pager=less"
  ]
  ++ lib.optionals util-linuxMinimal.hasCol [
    "--with-col=${util-linuxMinimal}/bin/col"
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    "ac_cv_func__set_invalid_parameter_handler=no"
    "ac_cv_func_posix_fadvise=no"
    "ac_cv_func_mempcpy=no"
  ]
  ++ lib.optionals stdenv.hostPlatform.isFreeBSD [
    "--enable-mandirs="
  ];

  preConfigure = ''
    ./bootstrap --no-git --gnulib-srcdir=${gnulib} --gen
    configureFlagsArray+=("--with-sections=1 n l 8 3 0 2 5 4 9 6 7")
  '';

  doCheck =
    !stdenv.hostPlatform.isMusl # iconv binary
  ;

  nativeCheckInputs = [ libiconv' ]; # for 'iconv' binary; make very sure it matches buildinput libiconv

  postInstall = ''
    # apropos/whatis uses program name to decide whether to act like apropos or whatis
    # (multi-call binary). `apropos` is actually just a symlink to whatis. So we need to
    # make sure that we don't wrap symlinks (since that changes argv[0] to the -wrapped name)
    find "$out/bin" -type f | while read file; do
      wrapProgram "$file" \
        --prefix PATH : "${
          lib.makeBinPath [
            groff
            gzip
            zstd
          ]
        }"
    done
  '';

  disallowedReferences = lib.optionals (stdenv.hostPlatform != stdenv.buildPlatform) [
    buildPackages.groff
  ];

  enableParallelBuilding = true;
  outputMan = "out"; # users will want `man man` to work

  passthru = {
    tests = {
      nixos = nixosTests.man;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Implementation of the standard Unix documentation system accessed using the man command";
    homepage = "http://man-db.nongnu.org";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ mdaniels5757 ];
    platforms = lib.platforms.unix;
    mainProgram = "man";
  };
})
