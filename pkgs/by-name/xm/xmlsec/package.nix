{
  lib,
  stdenv,
  fetchurl,
  fetchpatch,
  gnutls,
  libgcrypt,
  libtool,
  libxml2,
  libxslt,
  nss,
  openssl,
  pkg-config,
  runCommandCC,
  writeText,
}:

lib.fix (
  self:
  stdenv.mkDerivation (finalAttrs: {
    pname = "xmlsec";
    version = "1.3.7";

    src = fetchurl {
      hash = "sha256-2C6TtpuKogWmFrYpF6JpMiv2Oj6q+zd1AU5hdSsgE+o=";

      urls = [
        "https://www.aleksey.com/xmlsec/download/xmlsec1-${finalAttrs.version}.tar.gz"

        # for when the ${finalAttrs.version} gets older than the last two
        "https://www.aleksey.com/xmlsec/download/older-releases/xmlsec1-${finalAttrs.version}.tar.gz"
      ];
    };

    outputs = [
      "out"
      "dev"
    ];

    patches = [
      ./lt_dladdsearchdir.patch
      ./remove_bsd_base64_decode_flag.patch
      (fetchpatch {
        hash = "sha256-Hv8PaJXkXLq++NuCAJ4IvsYBPj8wkN7dBTniYucq18o=";
        # xmlDoc.encoding is no longer const in libxml 2.15, so fetch the fix
        url = "https://github.com/lsh123/xmlsec/commit/ef0e3b5cac04db13ce070b1e5bcad7dd7b0eb49b.patch?full_index=1";
      })
    ];

    postPatch = ''
      substituteAllInPlace src/dl.c
    '';

    nativeBuildInputs = [ pkg-config ];

    buildInputs = [
      libxml2
      gnutls
      libgcrypt
      libtool
      openssl
      nss
    ];

    propagatedBuildInputs = [
      # required by xmlsec/transforms.h
      libxslt
    ];

    # enable deprecated soap headers required by lasso
    # https://dev.entrouvert.org/issues/18771
    configureFlags = [ "--enable-soap" ];
    # otherwise libxmlsec1-gnutls.so won't find libgcrypt.so, after #909
    env.NIX_LDFLAGS = "-lgcrypt";
    doCheck = true;
    nativeCheckInputs = [ nss.tools ];

    preCheck = ''
      export TMPFOLDER=$(mktemp -d)
      substituteInPlace tests/testrun.sh --replace 'timestamp=`date +%Y%m%d_%H%M%S`' 'timestamp=19700101_000000'
    '';

    postInstall = ''
      moveToOutput "bin/xmlsec1-config" "$dev"
      moveToOutput "lib/xmlsec1Conf.sh" "$dev"
    '';

    enableParallelBuilding = true;

    passthru.tests.libxmlsec1-crypto =
      runCommandCC "libxmlsec1-crypto-test"
        {
          nativeBuildInputs = [ pkg-config ];

          buildInputs = [
            self
            libxml2
            libxslt
            libtool
          ];
        }
        ''
          $CC $(pkg-config --cflags --libs xmlsec1) -o crypto-test ${writeText "crypto-test.c" ''
            #include <xmlsec/xmlsec.h>
            #include <xmlsec/crypto.h>

            int main(int argc, char **argv) {
              return xmlSecInit() ||
                xmlSecCryptoDLLoadLibrary(argc > 1 ? argv[1] : 0) ||
                xmlSecCryptoInit();
            }
          ''}

          for crypto in "" gcrypt gnutls nss openssl; do
            ./crypto-test $crypto
          done
          touch $out
        '';

    meta = {
      description = "XML Security Library in C based on libxml2";
      homepage = "https://www.aleksey.com/xmlsec/";
      license = lib.licenses.mit;
      maintainers = [ ];
      platforms = with lib.platforms; linux ++ darwin;
      mainProgram = "xmlsec1";
      downloadPage = "https://www.aleksey.com/xmlsec/download.html";
    };
  })
)
