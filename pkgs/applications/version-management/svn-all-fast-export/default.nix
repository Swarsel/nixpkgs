{
  lib,
  stdenv,
  fetchFromGitHub,
  apr,
  qmake,
  qtbase,
  qttools,
  subversion,
}:

let
  version = "1.0.20";
in
stdenv.mkDerivation {
  inherit version;
  pname = "svn-all-fast-export";

  src = fetchFromGitHub {
    owner = "svn-all-fast-export";
    repo = "svn2git";
    rev = version;
    sha256 = "sha256-ALZ9wGEM2woELUdCxG1SSzIhOCHERsnrSnCVN2MH9Lo=";
  };

  nativeBuildInputs = [
    qmake
    qttools
  ];

  buildInputs = [
    apr.dev
    subversion.dev
    qtbase
  ];

  env.NIX_LDFLAGS = "-lsvn_fs-1";
  dontWrapQtApps = true;

  qmakeFlags = [
    "VERSION=${version}"
    "APR_INCLUDE=${apr.dev}/include/apr-1"
    "SVN_INCLUDE=${subversion.dev}/include/subversion-1"
  ];

  meta = {
    description = "Fast-import based converter for an svn repo to git repos";
    homepage = "https://github.com/svn-all-fast-export/svn2git";
    license = lib.licenses.gpl3;
    maintainers = [ lib.maintainers.flokli ];
    platforms = lib.platforms.all;
    mainProgram = "svn-all-fast-export";
  };
}
