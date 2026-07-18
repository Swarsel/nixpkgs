{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  libsodium,
  pcre2,
  batchSize ? 2048,
  regexSupport ? false,
}:

stdenv.mkDerivation rec {
  pname = "mkp224o";
  version = "1.7.0";

  src = fetchFromGitHub {
    owner = "cathugger";
    repo = "mkp224o";
    rev = "v${version}";
    sha256 = "sha256-OL3xhoxIS1OqfVp0QboENFdNH/e1Aq1R/MFFM9LNFbQ=";
  };

  buildCommand =
    let
      # compile few variants with different implementation of crypto
      # the fastest depends on a particular cpu
      variants = [
        {
          configureFlags = [ "--enable-ref10" ];
          suffix = "ref10";
        }
        {
          configureFlags = [ "--enable-donna" ];
          suffix = "donna";
        }
      ]
      ++ lib.optionals stdenv.hostPlatform.isx86 [
        {
          configureFlags = [ "--enable-donna-sse2" ];
          suffix = "donna-sse2";
        }
      ]
      ++ lib.optionals (!stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isx86_64) [
        {
          configureFlags = [ "--enable-amd64-51-30k" ];
          suffix = "amd64-51-30k";
        }
        {
          configureFlags = [ "--enable-amd64-64-24k" ];
          suffix = "amd64-64-24k";
        }
      ];
    in
    lib.concatMapStrings (
      { configureFlags, suffix }:
      ''
        install -D ${
          stdenv.mkDerivation {
            inherit version src;
            pname = "mkp224o-${suffix}";
            nativeBuildInputs = [ autoreconfHook ];
            buildInputs = [ libsodium ] ++ lib.optionals regexSupport [ pcre2 ];

            configureFlags =
              configureFlags
              ++ [ "--enable-batchnum=${builtins.toString batchSize}" ]
              ++ lib.optionals regexSupport [ "--enable-regex=yes" ];

            installPhase = "install -D mkp224o $out";
          }
        } $out/bin/mkp224o-${suffix}
      ''
    ) variants;

  meta = {
    description = "Vanity address generator for tor onion v3 (ed25519) hidden services";
    homepage = "http://cathug2kyi4ilneggumrenayhuhsvrgn6qv2y47bgeet42iivkpynqad.onion/";
    license = lib.licenses.cc0;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
}
