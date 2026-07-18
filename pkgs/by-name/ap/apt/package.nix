{
  lib,
  stdenv,
  fetchFromGitLab,
  bzip2,
  cmake,
  curl,
  db,
  docbook_xml_dtd_45,
  docbook_xsl,
  doxygen,
  dpkg,
  gettext,
  gnutls,
  gtest,
  libgcrypt,
  libgpg-error,
  libseccomp,
  libtasn1,
  libxslt,
  lz4,
  nix-update-script,
  p11-kit,
  perlPackages,
  pkg-config,
  triehash,
  udev,
  w3m,
  xxhash,
  xz,
  zstd,
  withDocs ? true,
  withNLS ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "apt";
  version = "3.3.1";

  src = fetchFromGitLab {
    owner = "apt-team";
    repo = "apt";
    rev = finalAttrs.version;
    hash = "sha256-93DR4MfKuJ4sF1BHCZyyR04v+WIoEMBW+GvLy7OhuWk=";
    domain = "salsa.debian.org";
  };

  # cycle detection; lib can't be split
  outputs = [
    "out"
    "dev"
    "doc"
    "man"
  ];

  nativeBuildInputs = [
    cmake
    dpkg # dpkg-architecture
    gettext # msgfmt
    gtest
    (lib.getBin libxslt)
    pkg-config
    triehash
    perlPackages.perl
  ]
  ++ lib.optionals withDocs [
    docbook_xml_dtd_45
    doxygen
    perlPackages.Po4a
    w3m
  ];

  buildInputs = [
    bzip2
    curl
    db
    dpkg
    gnutls
    gtest
    libgcrypt
    libgpg-error
    libseccomp
    libtasn1
    lz4
    p11-kit
    udev
    xxhash
    xz
    zstd
  ]
  ++ lib.optionals withNLS [
    gettext
  ];

  cmakeFlags = [
    (lib.cmakeOptionType "filepath" "BERKELEY_INCLUDE_DIRS" "${lib.getDev db}/include")
    (lib.cmakeOptionType "filepath" "DPKG_DATADIR" "${dpkg}/share/dpkg")
    (lib.cmakeOptionType "filepath" "DOCBOOK_XSL" "${docbook_xsl}/share/xml/docbook-xsl")
    (lib.cmakeOptionType "filepath" "GNUTLS_INCLUDE_DIR" "${lib.getDev gnutls}/include")
    (lib.cmakeFeature "DROOT_GROUP" "root")
    (lib.cmakeBool "USE_NLS" withNLS)
    (lib.cmakeBool "WITH_DOC" withDocs)
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Command-line package management tools used on Debian-based systems";
    homepage = "https://salsa.debian.org/apt-team/apt";
    changelog = "https://salsa.debian.org/apt-team/apt/-/raw/${finalAttrs.version}/debian/changelog";
    license = with lib.licenses; [ gpl2Plus ];
    maintainers = with lib.maintainers; [ VZstless ];
    platforms = lib.platforms.linux;
    mainProgram = "apt";
  };
})
