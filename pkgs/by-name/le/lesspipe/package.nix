{
  lib,
  stdenv,
  fetchFromGitHub,
  bash,
  binutils-unwrapped,
  coreutils,
  file,
  gnugrep,
  gnused,
  gnutar,
  iconv,
  makeWrapper,
  ncurses,
  perl,
  procps,
  # shell referenced dependencies
  resholve,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lesspipe";
  version = "2.20";

  src = fetchFromGitHub {
    owner = "wofr06";
    repo = "lesspipe";
    rev = "v${finalAttrs.version}";
    hash = "sha256-yb3IzdaMiv1PwqHOfSyHvmWXyStvK/XXC49saXVAJFU=";
  };

  postPatch = ''
    patchShebangs --build configure
    substituteInPlace configure --replace '/etc/bash_completion.d' '/share/bash-completion/completions'
  '';

  strictDeps = true;

  nativeBuildInputs = [
    perl
    makeWrapper
  ];

  buildInputs = [
    perl
    bash
  ];

  configureFlags = [
    "--shell=${bash}/bin/bash"
    "--prefix=/"
  ];

  postInstall = ''
    # resholve doesn't see strings in an array definition
    substituteInPlace $out/bin/lesspipe.sh --replace 'nodash strings' "nodash ${binutils-unwrapped}/bin/strings"

    ${resholve.phraseSolution "lesspipe.sh" {
      execer = [
        "cannot:${iconv}/bin/iconv"
        "cannot:${file}/bin/file"
      ];

      fake = {
        builtin = [ "setopt" ];

        # script guards usage behind has_cmd test function, it's safe to leave these external and optional
        external = [
          "cpio"
          "isoinfo"
          "cabextract"
          "bsdtar"
          "rpm2cpio"
          "bsdtar"
          "unzip"
          "ar"
          "unrar"
          "rar"
          "7zr"
          "7za"
          "isoinfo"
          "gzip"
          "bzip2"
          "lzip"
          "lzma"
          "xz"
          "brotli"
          "compress"
          "zstd"
          "lz4"
          "archive_color"
          "bat"
          "batcat"
          "pygmentize"
          "source-highlight"
          "vimcolor"
          "code2color"

          "w3m"
          "lynx"
          "elinks"
          "html2text"
          "xmq"
          "dtc"
          "pdftotext"
          "pdftohtml"
          "pdfinfo"
          "ps2ascii"
          "procyon"
          "ccze"
          "mdcat"
          "pandoc"
          "docx2txt"
          "libreoffice"
          "pptx2md"
          "mdcat"
          "xlscat"
          "odt2txt"
          "wvText"
          "catdoc"
          "broken_catppt"
          "sxw2txt"
          "groff"
          "mandoc"
          "unrtf"
          "dvi2tty"
          "pod2text"
          "perldoc"
          "h5dump"
          "ncdump"
          "matdump"
          "djvutxt"
          "openssl"
          "gpg"
          "plistutil"
          "plutil"
          "id3v2"
          "csvlook"
          "csvtable"
          "jq"
          "zlib-flate"
          "lessfilter"
          "snap"
          "locale" # call site is guarded by || so it's safe to leave dynamic
        ];
      };

      inputs = [
        coreutils
        file
        gnugrep
        gnused
        gnutar
        iconv
        procps
        ncurses
      ];

      interpreter = "${bash}/bin/bash";

      keep = [
        "$prog"
        "$c1"
        "$c2"
        "$c3"
        "$c4"
        "$c5"
        "$cmd"
        "$colorizer"
        "$HOME"
      ];

      scripts = [ "bin/lesspipe.sh" ];
    }}
    ${resholve.phraseSolution "lesscomplete" {
      execer = [
        "cannot:${file}/bin/file"
      ];

      fake = {
        builtin = [ "setopt" ];

        # script guards usage behind has_cmd test function, it's safe to leave these external and optional
        external = [
          "cpio"
          "isoinfo"
          "cabextract"
          "bsdtar"
          "rpm2cpio"
          "bsdtar"
          "unzip"
          "ar"
          "unrar"
          "rar"
          "7zr"
          "7za"
          "isoinfo"
          "gzip"
          "bzip2"
          "lzip"
          "lzma"
          "xz"
          "brotli"
          "compress"
          "zstd"
          "lz4"
        ];
      };

      inputs = [
        coreutils
        file
        gnugrep
        gnused
        gnutar
      ];

      interpreter = "${bash}/bin/bash";

      keep = [
        "$prog"
        "$c1"
        "$c2"
        "$c3"
        "$c4"
        "$c5"
        "$cmd"
      ];

      scripts = [ "bin/lesscomplete" ];
    }}
  '';

  configurePlatforms = [ ];
  dontBuild = true;
  installFlags = [ "DESTDIR=$(out)" ];

  meta = {
    description = "Preprocessor for less";

    longDescription = ''
      Usually lesspipe.sh is called as an input filter to less. With the help
      of that filter less will display the uncompressed contents of compressed
      (gzip, bzip2, compress, rar, 7-zip, lzip, xz or lzma) files. For files
      containing archives and directories, a table of contents will be
      displayed (e.g tar, ar, rar, jar, rpm and deb formats). Other supported
      formats include nroff, pdf, ps, dvi, shared library, MS word, OASIS
      (e.g. Openoffice), NetCDF, html, mp3, jpg, png, iso images, MacOSX bom,
      plist and archive formats, perl storable data and gpg encrypted files.
      This does require additional helper programs being installed.
    '';

    homepage = "https://github.com/wofr06/lesspipe";
    license = lib.licenses.gpl2Only;
    maintainers = [ lib.maintainers.martijnvermaat ];
    platforms = lib.platforms.all;
    mainProgram = "lesspipe.sh";
  };
})
