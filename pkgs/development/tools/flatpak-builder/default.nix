{
  lib,
  stdenv,
  fetchurl,
  acl,
  appstream,
  attr,
  binutils,
  breezy,
  bzip2,
  coreutils,
  cpio,
  curl,
  debugedit,
  docbook_xml_dtd_45,
  docbook_xsl,
  elfutils,
  flatpak,
  gettext,
  gitMinimal,
  glib,
  glibcLocales,
  gnumake,
  gnupg,
  gnutar,
  json-glib,
  libcap,
  libxml2,
  libxslt,
  libyaml,
  meson,
  ninja,
  nixosTests,
  ostree,
  patch,
  pkg-config,
  replaceVars,
  rpm,
  unzip,
  xmlto,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "flatpak-builder";
  version = "1.4.4";

  # fetchFromGitHub fetches an archive which does not contain the full source (https://github.com/flatpak/flatpak-builder/issues/558)
  src = fetchurl {
    url = "https://github.com/flatpak/flatpak-builder/releases/download/${finalAttrs.version}/flatpak-builder-${finalAttrs.version}.tar.xz";
    hash = "sha256-3CcVk5S6qiy1I/Uvh0Ry/1DRYZgyMyZMoqIuhQdB7Ho=";
  };

  outputs = [
    "out"
    "doc"
    "man"
    "installedTests"
  ];

  patches = [
    # patch taken from gtk_doc
    ./respect-xml-catalog-files-var.patch

    # Hardcode paths
    (replaceVars ./fix-paths.patch {
      brz = "${breezy}/bin/brz";
      cp = "${coreutils}/bin/cp";
      cpio = "${cpio}/bin/cpio";
      euelfcompress = "${elfutils}/bin/eu-elfcompress";
      eustrip = "${elfutils}/bin/eu-strip";
      git = "${gitMinimal}/bin/git";
      patch = "${patch}/bin/patch";
      rofilesfuse = "${ostree}/bin/rofiles-fuse";
      rpm2cpio = "${rpm}/bin/rpm2cpio";
      strip = "${binutils}/bin/strip";
      tar = "${gnutar}/bin/tar";
      unzip = "${unzip}/bin/unzip";
    })

    (replaceVars ./fix-test-paths.patch {
      inherit glibcLocales;
    })
    ./fix-test-prefix.patch
  ];

  nativeBuildInputs = [
    meson
    ninja
    docbook_xml_dtd_45
    docbook_xsl
    gettext
    libxml2
    libxslt
    pkg-config
    xmlto
  ];

  buildInputs = [
    acl
    appstream
    bzip2
    curl
    debugedit
    elfutils
    flatpak
    glib
    json-glib
    libcap
    libxml2
    libyaml
    ostree
  ];

  mesonFlags = [
    "-Dinstalled_tests=true"
    "-Dinstalled_test_prefix=${placeholder "installedTests"}"
  ];

  # Installed tests
  postFixup =
    let
      installed_testdir = "${placeholder "installedTests"}/libexec/installed-tests/flatpak-builder";
    in
    ''
      for file in ${installed_testdir}/{test-builder.sh,test-builder-python.sh,test-builder-deprecated.sh}; do
        patchShebangs $file
      done
    '';

  # Some scripts used by tests  need to use shebangs that are available in Flatpak runtimes.
  dontPatchShebangs = true;
  enableParallelBuilding = true;

  passthru = {
    installedTestsDependencies = [
      gnupg
      ostree
      gnumake
      attr
      libxml2
      appstream
    ];

    tests = {
      installedTests = nixosTests.installed-tests.flatpak-builder;
    };
  };

  meta = {
    description = "Tool to build flatpaks from source";
    homepage = "https://github.com/flatpak/flatpak-builder";
    license = lib.licenses.lgpl21Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "flatpak-builder";
  };
})
