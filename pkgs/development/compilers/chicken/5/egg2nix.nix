{
  lib,
  fetchFromGitHub,
  chickenEggs,
  eggDerivation,
}:

eggDerivation {
  pname = "egg2nix";
  version = "c5-git";

  src = fetchFromGitHub {
    owner = "corngood";
    repo = "egg2nix";
    rev = "chicken-5";
    sha256 = "1vfnhbcnyakywgjafhs0k5kpsdnrinzvdjxpz3fkwas1jsvxq3d1";
  };

  buildInputs = with chickenEggs; [
    args
    matchable
  ];

  meta = {
    description = "Generate nix-expression from CHICKEN scheme eggs";
    homepage = "https://github.com/the-kenny/egg2nix";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ corngood ];
    platforms = lib.platforms.unix;
    mainProgram = "egg2nix";
  };
}
