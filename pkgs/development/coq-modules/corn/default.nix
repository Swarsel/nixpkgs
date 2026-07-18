{
  lib,
  bignums,
  coq,
  coq-elpi,
  math-classes,
  mkCoqDerivation,
  version ? null,
}:

(mkCoqDerivation {
  inherit version;
  pname = "corn";

  propagatedBuildInputs = [
    bignums
    math-classes
  ];

  configureScript = "./configure.sh";

  defaultVersion =
    with lib.versions;
    lib.switch coq.coq-version [
      {
        case = (range "8.18" "8.20");
        out = "8.20.0";
      }
      {
        case = (range "8.17" "8.20");
        out = "8.19.0";
      }
      {
        case = (range "8.14" "8.18");
        out = "8.18.0";
      }
      {
        case = (range "8.11" "8.17");
        out = "8.16.0";
      }
      {
        case = (range "8.7" "8.15");
        out = "8.13.0";
      }
      {
        case = "8.6";
        out = "8.8.1";
      }
    ] null;

  dontAddPrefix = true;
  mlPlugin = true; # uses coq-bignums.plugin

  release = {
    "8.12.0".hash = "sha256:0b92vhyzn1j6cs84z2182fn82hxxj0bqq7hk6cs4awwb3vc7dkhi";
    "8.13.0".hash = "sha256:1wzr7mdsnf1rq7q0dvmv55vxzysy85b00ahwbs868bl7m8fk8x5b";
    "8.16.0".hash = "sha256-ZE/EEIndxHfo/9Me5NX4ZfcH0ZAQ4sRfZY7LRZfLXBQ=";
    "8.18.0".hash = "sha256-ow3mfarZ1PvBGf5WLnI8LdF3E+8A6fN7cOcXHrZJLo0=";
    "8.19.0".hash = "sha256-h5MlfRuv2hTbxGmpLUEGQO1YqQTwUNEHZzCfvdOU1TA=";
    "8.20.0".hash = "sha256-tl68REU6xTbSOzhPucQPd9A3YnnaMNbSY8gl4Seyp10=";
    "8.8.1".hash = "sha256:0gh32j0f18vv5lmf6nb87nr5450w6ai06rhrnvlx2wwi79gv10wp";
  };

  meta = {
    description = "Coq library for constructive analysis";
    homepage = "http://c-corn.github.io/";
    license = lib.licenses.gpl2;
    maintainers = [ lib.maintainers.vbgl ];
  };
}).overrideAttrs
  (o: {
    propagatedBuildInputs =
      o.propagatedBuildInputs
      ++ lib.optional (lib.versions.isGt "8.19.0" o.version || o.version == "dev") coq-elpi;
  })
