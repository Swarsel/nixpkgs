{
  lib,
  stdenv,
  fetchFromGitHub,
  asciidoctor,
  bash,
  binutils,
  bzip2,
  coreutils,
  cpio,
  docbook_xsl,
  findutils,
  gitUpdater,
  gnugrep,
  gnused,
  gnutar,
  gzip,
  kmod,
  libxslt,
  lz4,
  lzop,
  makeBinaryWrapper,
  pkg-config,
  squashfsTools,
  util-linux,
  xz,
  zstd,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "dracut";
  version = "111";

  src = fetchFromGitHub {
    owner = "dracut-ng";
    repo = "dracut";
    tag = finalAttrs.version;
    hash = "sha256-2jdS7/LGuLSBBXv1R/o8yjgwdXl2l2wNbZWxq01wSb0";
  };

  postPatch = ''
    substituteInPlace dracut.sh \
      --replace-fail "dracutbasedir=\"$""{dracutsysrootdir-}\"/usr/lib/dracut" \
        "if [ -n \"$""{dracutsysrootdir:-}\" ]; then dracutbasedir=\"$""{dracutsysrootdir}/usr/lib/dracut\" ; else dracutbasedir=\"$out/lib/dracut\" ; fi"
    substituteInPlace lsinitrd.sh \
      --replace-fail 'dracutbasedir=/usr/lib/dracut' "dracutbasedir=$out/lib/dracut"

    echo 'DRACUT_VERSION=${finalAttrs.version}' >dracut-version.sh
  '';

  strictDeps = true;

  nativeBuildInputs = [
    makeBinaryWrapper
    pkg-config
    asciidoctor
    libxslt
    docbook_xsl
  ];

  buildInputs = [
    bash
    kmod
  ];

  postFixup = ''
    wrapProgram $out/bin/dracut --prefix PATH : ${
      lib.makeBinPath [
        coreutils
        util-linux
      ]
    } --suffix DRACUT_PATH : ${
      lib.makeBinPath [
        bash
        binutils
        coreutils
        findutils
        gnugrep
        gnused
        gnutar
        stdenv.cc.libc # for ldd command
        util-linux
      ]
    }
    wrapProgram $out/bin/dracut-catimages --set PATH ${
      lib.makeBinPath [
        coreutils
        cpio
        findutils
        gzip
      ]
    }
    wrapProgram $out/bin/lsinitrd --set PATH ${
      lib.makeBinPath [
        binutils
        bzip2
        coreutils
        cpio
        gnused
        gzip
        lz4
        lzop
        squashfsTools
        util-linux
        xz
        zstd
      ]
    }
  '';

  __structuredAttrs = true;
  passthru.updateScript = gitUpdater { };

  meta = {
    description = "Event driven initramfs infrastructure";
    homepage = "https://dracut-ng.github.io/";
    changelog = "https://github.com/dracut-ng/dracut/blob/${finalAttrs.src.tag}/NEWS.md";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ tbutter ];
    platforms = lib.platforms.linux;
  };
})
