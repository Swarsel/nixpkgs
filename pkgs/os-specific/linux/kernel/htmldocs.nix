{
  lib,
  stdenv,
  graphviz,
  imagemagick,
  linux_latest,
  makeFontsConf,
  perl,
  python3,
  which,
}:

stdenv.mkDerivation {
  inherit (linux_latest) version src;
  pname = "linux-kernel-latest-htmldocs";

  postPatch = ''
    patchShebangs \
      Documentation/sphinx/parse-headers.pl \
      scripts/{get_abi.pl,get_feat.pl,kernel-doc,sphinx-pre-install} \
      tools/docs/sphinx-pre-install \
      tools/net/ynl/pyynl/ynl_gen_rst.py
  '';

  nativeBuildInputs = [
    graphviz
    imagemagick
    perl
    python3.pkgs.sphinx
    python3.pkgs.sphinx-rtd-theme
    python3.pkgs.pyyaml
    which
  ];

  makeFlags = [ "htmldocs" ];

  env.FONTCONFIG_FILE = makeFontsConf {
    fontDirectories = [ ];
  };

  preBuild = ''
    export XDG_CACHE_HOME="$(mktemp -d)"
  '';

  installPhase = ''
    mkdir -p $out/share/doc
    mv Documentation/output $out/share/doc/linux-doc
    cp -r Documentation/* $out/share/doc/linux-doc/
  '';

  meta = {
    inherit (linux_latest.meta) license;
    description = "Linux kernel html documentation";
    homepage = "https://www.kernel.org/doc/htmldocs/";
    maintainers = with lib.maintainers; [ sigmanificient ];
    platforms = lib.platforms.linux;
  };
}
