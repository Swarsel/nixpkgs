{
  lib,
  fetchFromGitHub,
  build-idris-package,
  contrib,
  patricia,
}:
build-idris-package {
  pname = "semidirect";
  version = "2018-07-02";

  src = fetchFromGitHub {
    owner = "clayrat";
    repo = "idris-semidirect";
    rev = "e19c58f7a25c53bba2ab058821e038bae3c093d2";
    sha256 = "0182r9z34kbv3l78pw4qf48ng3hqj4sqzy53074mb0b2c3pikcrl";
  };

  idrisDeps = [
    contrib
    patricia
  ];

  meta = {
    description = "Semidirect products in Idris";
    homepage = "https://github.com/clayrat/idris-semidirect";
    maintainers = [ lib.maintainers.brainrape ];
  };
}
