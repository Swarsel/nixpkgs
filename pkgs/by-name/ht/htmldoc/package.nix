{
  lib,
  stdenv,
  fetchFromGitHub,
  cups,
  htmldoc,
  libjpeg,
  libpng,
  pkg-config,
  testers,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "htmldoc";
  version = "1.9.23";

  src = fetchFromGitHub {
    owner = "michaelrsweet";
    repo = "htmldoc";
    rev = "v${finalAttrs.version}";
    hash = "sha256-GUJ5qNqNfjkzZMNGMj/w53wso6X1WOooJNE6drKqHks=";
  };

  # do not generate universal binary on Darwin
  # because it is not supported by Nix's clang
  postPatch = ''
    substituteInPlace configure --replace-fail "-arch x86_64 -arch arm64" ""
  '';

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    zlib
    cups
    libpng
    libjpeg
  ];

  passthru.tests = testers.testVersion {
    command = "htmldoc --version";
    package = htmldoc;
  };

  meta = {
    description = "Converts HTML files to PostScript and PDF";

    longDescription = ''
      HTMLDOC is a program that reads HTML source files or web pages and
      generates corresponding HTML, PostScript, or PDF files with an optional
      table of contents.
    '';

    homepage = "https://michaelrsweet.github.io/htmldoc";
    changelog = "https://github.com/michaelrsweet/htmldoc/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl2Only;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "htmldoc";
  };
})
