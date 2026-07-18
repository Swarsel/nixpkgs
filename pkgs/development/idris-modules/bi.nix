{
  lib,
  fetchFromGitHub,
  build-idris-package,
  contrib,
  pruviloj,
}:
build-idris-package {
  pname = "bi";
  version = "2018-06-25";

  src = fetchFromGitHub {
    owner = "sbp";
    repo = "idris-bi";
    rev = "6bd90fb30b06ab02438efb5059e2fc699fdc7787";
    sha256 = "1px550spigl8k1m1r64mjrw7qjvipa43xy95kz1pb5ibmy84d6r3";
  };

  idrisDeps = [
    contrib
    pruviloj
  ];

  ipkgName = "Bi";

  meta = {
    description = "Idris Binary Integer Arithmetic, porting PArith, NArith, and ZArith from Coq";
    homepage = "https://github.com/sbp/idris-bi";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.brainrape ];
  };
}
