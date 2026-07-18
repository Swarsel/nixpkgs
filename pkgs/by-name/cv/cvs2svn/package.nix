{
  lib,
  fetchurl,
  breezy,
  cvs,
  git,
  installShellFiles,
  makeWrapper,
  pypy2Packages,
  subversion,
}:

pypy2Packages.buildPythonApplication rec {
  pname = "cvs2svn";
  version = "2.5.0";

  src = fetchurl {
    url = "https://github.com/mhagger/cvs2svn/releases/download/${version}/cvs2svn-${version}.tar.gz";
    sha256 = "1ska0z15sjhyfi860rjazz9ya1gxbf5c0h8dfqwz88h7fccd22b4";
  };

  nativeBuildInputs = [
    makeWrapper
    installShellFiles
  ];

  doCheck = false; # Couldn't find node 'transaction...' in expected output tree

  nativeCheckInputs = [
    subversion
    git
    breezy
  ];

  checkPhase = "${pypy2Packages.python.interpreter} run-tests.py";

  postInstall = ''
    for i in bzr svn git; do
      wrapProgram $out/bin/cvs2$i \
          --prefix PATH : "${lib.makeBinPath [ cvs ]}"
      $out/bin/cvs2$i --man > csv2$i.1
      installManPage csv2$i.1
    done
  '';

  format = "setuptools";

  meta = {
    description = "Tool to convert CVS repositories to Subversion repositories";
    homepage = "https://github.com/mhagger/cvs2svn";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      makefu
      viraptor
    ];

    platforms = lib.platforms.unix;
  };
}
