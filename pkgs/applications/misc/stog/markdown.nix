{
  buildDunePackage,
  ocf_ppx,
  omd,
  stog,
}:

buildDunePackage {
  inherit (stog) version src;
  pname = "stog_markdown";
  buildInputs = [ ocf_ppx ];

  propagatedBuildInputs = [
    omd
    stog
  ];

  meta = stog.meta // {
    description = "Stog plugin to use markdown syntax";
  };
}
