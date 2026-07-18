{
  buildDunePackage,
  ocf_ppx,
  stog,
}:

buildDunePackage {
  inherit (stog) version src;
  pname = "stog_asy";
  buildInputs = [ ocf_ppx ];
  propagatedBuildInputs = [ stog ];

  meta = stog.meta // {
    description = "Stog plugin to include Asymptote results in documents";
  };
}
