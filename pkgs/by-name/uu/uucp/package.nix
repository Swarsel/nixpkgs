{
  lib,
  stdenv,
  fetchurl,
  autoreconfHook,
  fetchDebianPatch,
  testers,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "uucp";
  version = "1.07";

  src = fetchurl {
    url = "mirror://gnu/uucp/uucp-${finalAttrs.version}.tar.gz";
    sha256 = "0b5nhl9vvif1w3wdipjsk8ckw49jj1w85xw1mmqi3zbcpazia306";
  };

  patches = [
    ./socklen_t.patch
    (fetchDebianPatch {
      inherit (finalAttrs) pname version;
      debianRevision = "31";
      hash = "sha256-6Aqghz6P+bWULHOXCQIdQLRuaE+Lci7t5ojQXJOyeA0=";
      patch = "configure.patch";
    })
    (fetchDebianPatch {
      inherit (finalAttrs) pname version;
      debianRevision = "31";
      hash = "sha256-EsJqZCV4x7ggzpoa4OaibCLvF8L8FGGnLlBtr4Cee18=";
      patch = "implicit.patch";
    })
    (fetchDebianPatch {
      inherit (finalAttrs) pname version;
      debianRevision = "31";
      hash = "sha256-+9H/gQLwkPx4GeWiZyy6oQdysvw2+P1O8wP5It/Tg5k=";
      patch = "gcc15.patch";
    })
  ];

  # Regenerate `configure`; the checked in version was generated in 2002 and
  # contains snippets like `main(){return(0);}` that modern compilers dislike.
  nativeBuildInputs = [ autoreconfHook ];
  makeFlags = [ "AR:=$(AR)" ];
  hardeningDisable = [ "format" ];

  prePatch = ''
    # do not set sticky bit in nix store
    substituteInPlace Makefile.am \
      --replace-fail 4555 0555
    sed -i '/chown $(OWNER)/d' Makefile.am
  '';

  passthru.tests.version = testers.testVersion {
    package = finalAttrs.finalPackage;
  };

  meta = {
    description = "Unix-unix cp over serial line, also includes cu program";

    longDescription = ''
      Taylor UUCP is a free implementation of UUCP and is the standard
      UUCP used on the GNU system.  If you don't know what UUCP is chances
      are, nowadays, that you won't need it.  If you do need it, you've
      just found one of the finest UUCP implementations available.
    '';

    homepage = "https://www.gnu.org/software/uucp/uucp.html";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.all;
    mainProgram = "uucp";
  };
})
