{
  lib,
  coq,
  coq-elpi,
  mkCoqDerivation,
  stdlib,
  version ? null,
}:

mkCoqDerivation {
  inherit version;
  pname = "trakt";

  propagatedBuildInputs = [
    coq-elpi
    stdlib
  ];

  defaultVersion =
    with lib.versions;
    lib.switch
      [ coq.version ]
      [
        {
          cases = [ (range "8.15" "8.17") ];
          out = "1.2";
        }
        {
          cases = [ (isEq "8.13") ];
          out = "1.2+8.13";
        }
        {
          cases = [ (range "8.13" "8.17") ];
          out = "1.1";
        }
      ]
      null;

  opam-name = "rocq-trakt";
  owner = "ecranceMERCE";
  release."1.0".hash = "sha256-Qhw5fWFYxUFO2kIWWz/og+4fuy9aYG27szfNk3IglhY=";
  release."1.1".hash = "sha256-JmrtM9WcT8Bfy0WZCw8xdubuMomyXmfLXJwpnCNrvsg=";
  release."1.2".hash = "sha256-YQRtK2MjjsMlytdu9iutUDKhwOo4yWrSwhyBb2zNHoE=";
  release."1.2+8.13".hash = "sha256-hozms4sPSMr4lFkJ20x+uW9Wqt067bifnPQxdGyKhQQ=";
  useDuneifVersion = v: v != null && (v == "dev" || lib.versions.isGt "1.2.1" v);

  meta = {
    description = "Generic goal preprocessing tool for proof automation tactics in Coq";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ siraben ];
    platforms = lib.platforms.unix;
  };
}
