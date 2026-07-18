{
  lib,
  stdenv,
  buildPackages,
  docbook_xml_dtd_44,
  docbook_xsl,
  fetchgit,
  gitUpdater,
  libcap,
  meson,
  ninja,
  pkg-config,
  python3,
  xmlto,
  withFuzzing ? stdenv.hostPlatform.isLinux,
  withLibcap ? stdenv.hostPlatform.isLinux,
  withSeccomp ? stdenv.hostPlatform.isLinux,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pax-utils";
  version = "1.3.10";

  src = fetchgit {
    url = "https://anongit.gentoo.org/git/proj/pax-utils.git";
    rev = "v${finalAttrs.version}";
    hash = "sha256-qoFXQ/RqvdjsVhXVZZjWKnE0khak9HjOGi/UrfTLS8M=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    docbook_xml_dtd_44
    docbook_xsl
    meson
    ninja
    pkg-config
    xmlto
  ];

  buildInputs = lib.optionals withLibcap [ libcap ];
  # Needed for lddtree
  propagatedBuildInputs = [ (python3.withPackages (p: with p; [ pyelftools ])) ];

  mesonFlags = [
    (lib.mesonBool "use_fuzzing" withFuzzing)
    (lib.mesonEnable "use_libcap" withLibcap)
    (lib.mesonBool "use_seccomp" withSeccomp)
  ];

  depsBuildBuild = [ buildPackages.stdenv.cc ];

  passthru.updateScript = gitUpdater {
    rev-prefix = "v";
    url = "https://anongit.gentoo.org/git/proj/pax-utils.git";
  };

  meta = {
    description = "ELF utils that can check files for security relevant properties";

    longDescription = ''
      A suite of ELF tools to aid auditing systems. Contains
      various ELF related utils for ELF32, ELF64 binaries useful
      for displaying PaX and security info on a large groups of
      binary files.
    '';

    homepage = "https://wiki.gentoo.org/wiki/Hardened/PaX_Utilities";
    license = lib.licenses.gpl2Only;

    maintainers = with lib.maintainers; [
      thoughtpolice
    ];

    platforms = lib.platforms.unix;
  };
})
