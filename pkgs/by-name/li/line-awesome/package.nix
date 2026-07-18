{
  lib,
  stdenv,
  fetchurl,
  installFonts,
  unzip,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "line-awesome";
  version = "1.3.0";

  src = fetchurl {
    url = "https://maxst.icons8.com/vue-static/landings/line-awesome/line-awesome/${finalAttrs.version}/line-awesome-${finalAttrs.version}.zip";
    sha256 = "07qkz8s1wjh5xwqlq1b4lpihr1zah3kh6bnqvfwvncld8l9wjqfk";
  };

  outputs = [
    "out"
    "webfont"
  ];

  nativeBuildInputs = [
    unzip
    installFonts
  ];

  sourceRoot = "${finalAttrs.version}/fonts";

  meta = {
    description = "Replace Font Awesome with modern line icons";

    longDescription = ''
      This package includes only the TTF, WOFF and WOFF2 fonts. For full CSS etc. see the project website.
    '';

    homepage = "https://icons8.com/line-awesome";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ puzzlewolf ];
    platforms = lib.platforms.all;
  };
})
