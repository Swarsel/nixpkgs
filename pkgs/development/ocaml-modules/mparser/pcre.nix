{
  buildDunePackage,
  mparser,
  ocaml_pcre,
}:

buildDunePackage {
  inherit (mparser) src version;
  pname = "mparser-pcre";

  propagatedBuildInputs = [
    ocaml_pcre
    mparser
  ];

  meta = mparser.meta // {
    description = "PCRE-based regular expressions";
  };
}
