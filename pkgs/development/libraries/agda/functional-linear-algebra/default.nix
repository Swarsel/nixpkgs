{
  lib,
  fetchFromGitHub,
  mkDerivation,
  standard-library,
}:

mkDerivation rec {
  pname = "functional-linear-algebra";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "ryanorendorff";
    repo = "functional-linear-algebra";
    rev = "v${version}";
    sha256 = "sha256-3nme/eH4pY6bD0DkhL4Dj/Vp/WnZqkQtZTNk+n1oAyY=";
  };

  buildInputs = [ standard-library ];

  meta = {
    description = ''
      Formalizing linear algebra in Agda by representing matrices as functions
      from one vector space to another.
    '';

    homepage = "https://github.com/ryanorendorff/functional-linear-algebra";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ ryanorendorff ];
    platforms = lib.platforms.unix;
  };
}
