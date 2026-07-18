{
  buildDunePackage,
  mparser,
  re,
}:

buildDunePackage {
  inherit (mparser) src version;
  pname = "mparser-re";

  propagatedBuildInputs = [
    mparser
    re
  ];

  meta = mparser.meta // {
    description = "MParser plugin: RE-based regular expressions";
  };
}
