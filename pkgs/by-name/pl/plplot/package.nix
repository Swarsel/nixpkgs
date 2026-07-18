{
  lib,
  stdenv,
  fetchurl,
  cairo,
  cmake,
  libx11,
  pango,
  pkg-config,
  wxwidgets_3_2,
  enablePNG ? false,
  enableWX ? false,
  enableXWin ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "plplot";
  version = "5.15.0";

  src = fetchurl {
    url = "mirror://sourceforge/project/plplot/plplot/${finalAttrs.version}%20Source/plplot-${finalAttrs.version}.tar.gz";
    sha256 = "0ywccb6bs1389zjfmc9zwdvdsvlpm7vg957whh6b5a96yvcf8bdr";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs =
    lib.optional enableWX wxwidgets_3_2
    ++ lib.optional enableXWin libx11
    ++ lib.optionals enablePNG [
      cairo
      pango
    ];

  cmakeFlags = [
    "-DBUILD_TEST=ON"
  ];

  doCheck = true;

  passthru = {
    inherit
      enableWX
      enableXWin
      libx11
      ;

    # backwards compat
    libX11 = libx11;
  };

  meta = {
    description = "Cross-platform scientific graphics plotting library";
    homepage = "https://plplot.org";
    license = lib.licenses.lgpl2;
    maintainers = with lib.maintainers; [ bcdarwin ];
    platforms = lib.platforms.unix;
    mainProgram = "pltek";
  };
})
