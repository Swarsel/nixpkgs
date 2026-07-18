{
  atdgen,
  atdgen-runtime,
  buildDunePackage,
  github,
  yojson,
}:

buildDunePackage {
  inherit (github) version src;
  pname = "github-data";

  postPatch = ''
    substituteInPlace lib_data/dune --replace-warn 'atdgen)' 'atdgen-runtime)'
  '';

  nativeBuildInputs = [
    atdgen
  ];

  propagatedBuildInputs = [
    yojson
    atdgen-runtime
  ];

  meta = github.meta // {
    description = "GitHub APIv3 data library";
  };
}
