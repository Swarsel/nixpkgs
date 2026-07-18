{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
}:

stdenv.mkDerivation rec {
  pname = "simpleproxy";
  version = "3.5";

  src = fetchFromGitHub {
    inherit rev;
    owner = "vzaliva";
    repo = "simpleproxy";
    sha256 = "1my9g4vp19dikx3fsbii4ichid1bs9b9in46bkg05gbljhj340f6";
  };

  nativeBuildInputs = [ autoreconfHook ];
  rev = "v.${version}";

  meta = {
    description = "Simple TCP proxy";
    homepage = "https://github.com/vzaliva/simpleproxy";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.montag451 ];
    mainProgram = "simpleproxy";
  };
}
