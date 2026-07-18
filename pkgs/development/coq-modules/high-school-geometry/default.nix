{
  lib,
  coq,
  mkCoqDerivation,
  version ? null,
}:

mkCoqDerivation {
  inherit version;
  pname = "high-school-geometry";

  defaultVersion =
    with lib.versions;
    lib.switch coq.coq-version [
      {
        case = range "8.16" "8.20";
        out = "8.16";
      }
      {
        case = range "8.12" "8.16";
        out = "8.13";
      }
      {
        case = "8.12";
        out = "8.12";
      }
      {
        case = "8.11";
        out = "8.11";
      }
    ] null;

  release = {
    "8.11".hash = "sha256-sVGeBBAJ7a7f+EJU1aSUvIVe9ip9PakY4379XWvvoqw=";
    "8.12".hash = "sha256-OF7sahU+5Ormkcrd8t6p2Kp/B2/Q/6zYTV3/XBvlGHc=";
    "8.13".hash = "sha256-5F/6155v0bWi5t7n4qU/GuR6jENngvWIIqJGPURzIeQ=";
    "8.16".hash = "sha256-HvUrZ6l7wCshuKUZs8rvfMkTEv+oXuogI5LICcD8Bn8=";
  };

  releaseRev = v: "v${v}";
  repo = "HighSchoolGeometry";

  meta = {
    description = "Geometry in Coq for French high school";
    license = lib.licenses.lgpl21Plus;
    maintainers = with lib.maintainers; [ definfo ];
  };
}
