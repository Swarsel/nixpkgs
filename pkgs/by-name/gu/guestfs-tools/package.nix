{
  lib,
  stdenv,
  fetchurl,
  bash-completion,
  bison,
  cdrkit,
  cpio,
  curl,
  flex,
  getopt,
  gitUpdater,
  glib,
  gnupg,
  hivex,
  jansson,
  libguestfs-with-appliance,
  libosinfo,
  libvirt,
  libxml2,
  makeWrapper,
  ncurses,
  ocamlPackages,
  openssl,
  pcre2,
  perlPackages,
  pkg-config,
  qemu,
  xz,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "guestfs-tools";
  version = "1.52.3";

  src = fetchurl {
    url = "https://download.libguestfs.org/guestfs-tools/${lib.versions.majorMinor finalAttrs.version}-stable/guestfs-tools-${finalAttrs.version}.tar.gz";
    hash = "sha256-0xLCwj6TXU5b+tUewhKE9X0E+FN0MpX6+V+WHFxmiEc=";
  };

  postPatch = ''
    # If it uses the executable name, then there's nothing we can do
    # when wrapping to stop it looking in
    # $out/etc/.virt-builder-wrapped, which won't exist.
    substituteInPlace common/mlstdutils/std_utils.ml \
        --replace Sys.executable_name '(Array.get Sys.argv 0)'
  '';

  nativeBuildInputs = [
    bison
    cdrkit
    cpio
    flex
    getopt
    makeWrapper
    pkg-config
    qemu
  ]
  ++ (with perlPackages; [
    GetoptLong
    libintl-perl
    ModuleBuild
    perl
    Po4a
  ])
  ++ (with ocamlPackages; [
    findlib
    ocaml
    ounit2
  ]);

  buildInputs = [
    bash-completion
    glib
    hivex
    jansson
    libguestfs-with-appliance
    libosinfo
    libvirt
    libxml2
    ncurses
    openssl
    pcre2
    xz
  ];

  makeFlags = [
    "LIBGUESTFS_PATH=${libguestfs-with-appliance}/lib/guestfs"
  ];

  preConfigure = ''
    patchShebangs ocaml-dep.sh.in ocaml-link.sh.in run.in
  '';

  postInstall = ''
    wrapProgram $out/bin/virt-builder \
      --argv0 virt-builder \
      --prefix PATH : ${
        lib.makeBinPath [
          curl
          gnupg
        ]
      }:$out/bin \
      --suffix VIRT_BUILDER_DIRS : /etc:$out/etc
    wrapProgram $out/bin/virt-win-reg \
      --prefix PERL5LIB : ${
        with perlPackages;
        makeFullPerlPath [
          hivex
          libintl-perl
          libguestfs-with-appliance
        ]
      }
  '';

  enableParallelBuilding = true;

  installFlags = [
    "BASH_COMPLETIONS_DIR=${placeholder "out"}/share/bash-completion/completions"
  ];

  passthru.updateScript = gitUpdater {
    odd-unstable = true;
    rev-prefix = "v";
    url = "https://github.com/libguestfs/guestfs-tools";
  };

  meta = {
    description = "Extra tools for accessing and modifying virtual machine disk images";
    homepage = "https://libguestfs.org/";
    changelog = "https://www.libguestfs.org/guestfs-tools-release-notes-${lib.versions.majorMinor finalAttrs.version}.1.html";

    license = with lib.licenses; [
      gpl2Plus
      lgpl21Plus
    ];

    maintainers = [ ];
    platforms = lib.platforms.linux;
    hydraPlatforms = [ ];
  };
})
