{
  lib,
  stdenv,
  fetchFromGitHub,
  chez,
  chez-mit,
  chez-srfi,
}:

stdenv.mkDerivation rec {
  pname = "chez-scmutils";
  version = "0.2";

  src = fetchFromGitHub {
    owner = "fedeinthemix";
    repo = "chez-scmutils";
    rev = "v${version}";
    sha256 = "sha256-y2ug7GfmkJC6jddgB8YllsumjmGxFJxTGTpPf1Vcs/s=";
  };

  buildInputs = [
    chez
    chez-srfi
    chez-mit
  ];

  makeFlags = [
    "CHEZ=${lib.getExe chez}"
    "PREFIX=$(out)"
    "CHEZSCHEMELIBDIRS=${chez-srfi}/${lib-path}:${chez-mit}/${lib-path}"
  ];

  doCheck = false;
  lib-path = "lib/csv${lib.versions.majorMinor chez.version}-site";

  meta = {
    description = "Port of the 'MIT Scmutils' library to Chez Scheme";
    homepage = "https://github.com/fedeinthemix/chez-scmutils/";
    license = lib.licenses.gpl3;
    maintainers = [ lib.maintainers.jitwit ];
  };

}
