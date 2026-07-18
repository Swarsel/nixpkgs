{
  lib,
  stdenv,
  fetchFromGitHub,
  ronn,
  shocco,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "roundup";
  version = "0.0.6";

  src = fetchFromGitHub {
    owner = "bmizerany";
    repo = "roundup";
    rev = "v${finalAttrs.version}";
    sha256 = "0nxaqmbv8mdvq9wcaqxk6k5mr31i68jzxf1wxa6pp7xp4prwdc9z";
  };

  nativeBuildInputs = [
    ronn
    shocco
  ];

  preInstall = ''
    for i in 1 5; do
      mkdir -p $out/share/man/man$i
    done
  '';

  installTargets = [
    "install"
    "install-man"
  ];

  prePatch = ''
    # Don't change $PATH
    substituteInPlace configure --replace PATH= NIRVANA=
    # There are only man pages in sections 1 and 5 \
    substituteInPlace Makefile --replace "{1..9}" "1 5"
  '';

  meta = {
    description = "Unit testing tool for running test plans which are written in any POSIX shell";
    homepage = "http://bmizerany.github.io/roundup/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
    platforms = lib.platforms.all;
    mainProgram = "roundup";
  };
})
