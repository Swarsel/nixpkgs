{
  boost,
  faust,
  ladspa-header,
}:

faust.wrapWithBuildEnv {

  propagatedBuildInputs = [
    boost
    ladspa-header
  ];

  baseName = "faust2ladspa";

}
