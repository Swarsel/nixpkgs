{
  lib,
  fetchFromGitHub,
  buildGoModule,
  fetchpatch,
}:

buildGoModule (finalAttrs: {
  pname = "filtron";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "asciimoo";
    repo = "filtron";
    rev = "v${finalAttrs.version}";
    hash = "sha256-RihxlJvbHq5PaJz89NHl/wyXrKjSiC4XYAs7LSKAo6E=";
  };

  patches = [
    # Update golang version in go.mod
    (fetchpatch {
      hash = "sha256-QGR6YetEzA/b6tC4uD94LBkWv0+9PG7RD72Tpkn2gQU=";
      url = "https://github.com/asciimoo/filtron/commit/365a0131074b3b12aaa65194bfb542182a63413c.patch";
    })
    # Add missing go.sum file
    (fetchpatch {
      hash = "sha256-BhHbXDKiRjSzC6NKhKUiH6rjt/EgJcEprHMMJ1x/wiQ=";
      url = "https://github.com/asciimoo/filtron/commit/077769282b4e392e96a194c8ae71ff9f693560ea.patch";
    })
  ];

  vendorHash = "sha256-1DRR16WiBGvhOpq12L5njJJRRCIA7ajs1Py9j/3cWPE=";

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "Reverse HTTP proxy to filter requests by different rules";
    homepage = "https://github.com/asciimoo/filtron";
    license = lib.licenses.agpl3Only;
    maintainers = [ lib.maintainers.dasj19 ];
    platforms = lib.platforms.linux;
    mainProgram = "filtron";
  };
})
