{
  lib,
  stdenv,
  fetchurl,
  asciidoc,
  bzip2,
  coreutils,
  docbook_xsl,
  docutils,
  gnused,
  groff,
  gzip,
  libxml2,
  libxslt,
  luajit,
  lzip,
  nixosTests,
  openssl,
  pkg-config,
  python3Packages,
  xz,
  zlib,
  zstd,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cgit";
  version = "1.3.1";

  src = fetchurl {
    url = "https://git.zx2c4.com/cgit/snapshot/cgit-${finalAttrs.version}.tar.xz";
    sha256 = "c40fd71e120783d5e57d822208f3e17333cde2cd4baf3e7c8c75630b68afe12a";
  };

  postPatch = ''
    sed -e 's|"gzip"|"${gzip}/bin/gzip"|' \
        -e 's|"bzip2"|"${bzip2.bin}/bin/bzip2"|' \
        -e 's|"lzip"|"${lzip}/bin/lzip"|' \
        -e 's|"xz"|"${xz.bin}/bin/xz"|' \
        -e 's|"zstd"|"${zstd}/bin/zstd"|' \
        -i ui-snapshot.c

    substituteInPlace filters/html-converters/man2html \
      --replace 'groff' '${groff}/bin/groff'

    substituteInPlace filters/html-converters/rst2html \
      --replace 'rst2html.py' '${docutils}/bin/rst2html.py'
  '';

  nativeBuildInputs = [
    pkg-config
    asciidoc
  ]
  ++ (with python3Packages; [
    python
    wrapPython
  ]);

  buildInputs = [
    openssl
    zlib
    libxml2
    libxslt
    luajit
    docbook_xsl
  ];

  makeFlags = [
    "prefix=$(out)"
    "CGIT_SCRIPT_PATH=$(out)/cgit/"
    "CC=${stdenv.cc.targetPrefix}cc"
    "AR=${stdenv.cc.targetPrefix}ar"
  ];

  # Give cgit a git source tree and pass configuration parameters (as make
  # variables).
  preBuild = ''
    mkdir -p git
    tar --strip-components=1 -xf "$gitSrc" -C git
  '';

  postInstall = ''
    # Install manpage.
    make install-man $makeFlags

    wrapPythonProgramsIn "$out/lib/cgit/filters" "$out ''${pythonPath[*]}"

    for script in $out/lib/cgit/filters/*.sh $out/lib/cgit/filters/html-converters/txt2html; do
      wrapProgram $script --prefix PATH : '${
        lib.makeBinPath [
          coreutils
          gnused
        ]
      }'
    done
  '';

  enableParallelBuilding = true;

  # cgit is tightly coupled with git and needs a git source tree to build.
  # IMPORTANT: Remember to check which git version cgit needs on every version
  # bump (look for "GIT_VER" in the top-level Makefile).
  gitSrc = fetchurl {
    hash = "sha256-9okWI2TBDeee+Jqo2/SHMesFfjTtu9IKylEM4BVGgaM=";
    url = "mirror://kernel/software/scm/git/git-2.54.0.tar.xz";
  };

  pythonPath = with python3Packages; [
    pygments
    markdown
  ];

  separateDebugInfo = true;
  stripDebugList = [ "cgit" ];
  passthru.tests = { inherit (nixosTests) cgit; };

  meta = {
    description = "Web frontend for git repositories";
    homepage = "https://git.zx2c4.com/cgit/about/";
    license = lib.licenses.gpl2;

    maintainers = with lib.maintainers; [
      bjornfor
      qyliss
      sternenseemann
    ];

    platforms = lib.platforms.linux;
  };
})
