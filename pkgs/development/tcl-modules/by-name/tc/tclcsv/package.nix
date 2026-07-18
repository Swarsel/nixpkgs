{
  lib,
  fetchzip,
  mkTclDerivation,
}:

mkTclDerivation rec {
  pname = "tclcsv";
  version = "2.4.3";

  src = fetchzip {
    url = "mirror://sourceforge/tclcsv/tclcsv${version}-src.tar.gz";
    hash = "sha256-bNRMgIyUSy4TnOGq9FPCXr79NIkcRfy2SqO5/i+DC/w=";
  };

  meta = {
    description = "Tcl extension for reading and writing CSV files";
    homepage = "https://tclcsv.magicsplat.com/";
    changelog = "https://tclcsv.magicsplat.com/#_version_history";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ fgaz ];
    downloadPage = "https://sourceforge.net/projects/tclcsv/files/";
  };
}
