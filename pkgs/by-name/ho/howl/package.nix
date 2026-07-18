{
  lib,
  stdenv,
  fetchurl,
  gtk3,
  librsvg,
  makeWrapper,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "howl";
  version = "0.6";

  # Use the release tarball containing pre-downloaded dependencies sources
  src = fetchurl {
    url = "https://github.com/howl-editor/howl/releases/download/${finalAttrs.version}/howl-${finalAttrs.version}.tgz";
    sha256 = "1qc58l3rkr37cj6vhf8c7bnwbz93nscyraz7jxqwjq6k4gj0cjw3";
  };

  nativeBuildInputs = [
    makeWrapper
    pkg-config
  ];

  buildInputs = [
    gtk3
    librsvg
  ];

  # Required for the program to properly load its SVG assets
  postInstall = ''
    wrapProgram $out/bin/howl \
      --set GDK_PIXBUF_MODULE_FILE "$GDK_PIXBUF_MODULE_FILE"
  '';

  enableParallelBuilding = true;
  # The Makefile uses "/usr/local" if not explicitly overridden
  installFlags = [ "PREFIX=$(out)" ];
  sourceRoot = "howl-${finalAttrs.version}/src";

  meta = {
    description = "General purpose, fast and lightweight editor with a keyboard-centric minimalistic user interface";
    homepage = "https://howl.io/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ euxane ];

    # Howl builds fail for aarch64-linux
    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];

    mainProgram = "howl";
  };
})
