{
  # for mirage-crypro-rng-lwt 1.2.0
  # It is removed from mirage-crypto 2.1.0 now.
  fetchurl,
  buildDunePackage,
  camlp-streams,
  caqti-lwt,
  cstruct,
  digestif,
  dream-httpaf,
  dream-pure,
  duration,
  graphql-lwt,
  h2-lwt-unix,
  httpun-lwt-unix,
  httpun-ws,
  lambdasoup,
  logs,
  lwt,
  lwt_ppx,
  lwt_ssl,
  magic-mime,
  markup,
  mirage-clock,
  mirage-crypto-rng,
  mtime,
  multipart_form-lwt,
  ssl,
  unstrctrd,
  uri,
  yojson,
}:

let
  mirage-crypto-rng-lwt = buildDunePackage (finalAttrs: {
    pname = "mirage-crypto-rng-lwt";
    version = "1.2.0";

    src = fetchurl {
      url = "https://github.com/mirage/mirage-crypto/releases/download/v${finalAttrs.version}/mirage-crypto-${finalAttrs.version}.tbz";
      hash = "sha256-CVQrzZbB02j/m6iFMQX0wXgdjJTCQA3586wGEO4H5n4=";
    };

    propagatedBuildInputs = [
      mirage-crypto-rng
      duration
      logs
      mtime
      lwt
    ];

    doCheck = true;
  });
in

buildDunePackage {
  inherit (dream-pure) version src;
  pname = "dream";
  # Compatibility with httpun 0.2.0 and h2 0.13
  patches = [ ./httpun.patch ];
  buildInputs = [ lwt_ppx ];

  propagatedBuildInputs = [
    camlp-streams
    caqti-lwt
    cstruct
    digestif
    dream-httpaf
    dream-pure
    graphql-lwt
    h2-lwt-unix
    httpun-lwt-unix
    httpun-ws
    lambdasoup
    lwt_ssl
    magic-mime
    markup
    mirage-clock
    mirage-crypto-rng
    mirage-crypto-rng-lwt
    multipart_form-lwt
    ssl
    unstrctrd
    uri
    yojson
  ];

  meta = dream-pure.meta // {
    description = "Tidy, feature-complete Web framework";
  };
}
