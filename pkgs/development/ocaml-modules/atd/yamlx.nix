{
  atd-jsonlike,
  buildDunePackage,
  yamlx,
}:

buildDunePackage {
  inherit (atd-jsonlike) version src;
  pname = "atd-yamlx";

  propagatedBuildInputs = [
    atd-jsonlike
    yamlx
  ];

  meta = atd-jsonlike.meta // {
    description = "YAML-to-jsonlike bridge for use with ATD code generators";
  };
}
