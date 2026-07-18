{
  lib,
  stdenv,
  fetchurl,
  libiconv,
  testers,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libidn";
  version = "1.44";

  src = fetchurl {
    url = "mirror://gnu/libidn/libidn-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-SZYIurOmVlCg6lKIjBOo3uvj9xQI4xms2exS4C6xOVk=";
  };

  outputs = [
    "bin"
    "dev"
    "out"
    "info"
    "devdoc"
  ];

  buildInputs = lib.optional stdenv.hostPlatform.isDarwin libiconv;
  hardeningDisable = [ "format" ];
  passthru.tests.pkg-config = testers.testMetaPkgConfig finalAttrs.finalPackage;

  meta = {
    description = "Library for internationalized domain names";

    longDescription = ''
      GNU Libidn is a fully documented implementation of the
      Stringprep, Punycode and IDNA specifications.  Libidn's purpose
      is to encode and decode internationalized domain names.  The
      native C, C\# and Java libraries are available under the GNU
      Lesser General Public License version 2.1 or later.

      The library contains a generic Stringprep implementation.
      Profiles for Nameprep, iSCSI, SASL, XMPP and Kerberos V5 are
      included.  Punycode and ASCII Compatible Encoding (ACE) via IDNA
      are supported.  A mechanism to define Top-Level Domain (TLD)
      specific validation tables, and to compare strings against those
      tables, is included.  Default tables for some TLDs are also
      included.
    '';

    homepage = "https://www.gnu.org/software/libidn/";
    changelog = "https://codeberg.org/libidn/libidn/src/tag/v${finalAttrs.version}/NEWS";
    license = lib.licenses.lgpl2Plus;
    platforms = lib.platforms.all;
    mainProgram = "idn";
    pkgConfigModules = [ "libidn" ];
  };
})
