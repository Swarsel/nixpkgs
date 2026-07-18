{
  lib,
  stdenv,
  fetchFromGitHub,
  txt2tags,
  unzip,
}:

stdenv.mkDerivation {
  pname = "libixp";
  version = "0-unstable-2022-04-04";

  src = fetchFromGitHub {
    owner = "0intro";
    repo = "libixp";
    rev = "ca2acb2988e4f040022f0e2094c69ab65fa6ec53";
    hash = "sha256-S25DmXJ7fN0gXLV0IzUdz8hXPTYEHmaSG7Mnli6GQVc=";
  };

  postPatch = lib.optionalString stdenv.cc.isClang ''
    substituteInPlace mk/ixp.mk \
      --replace "©" "C "
  '';

  nativeBuildInputs = [ unzip ];
  buildInputs = [ txt2tags ];

  postConfigure = ''
    sed -i -e "s|^PREFIX.*=.*$|PREFIX = $out|" config.mk
  '';

  meta = {
    description = "Portable, simple C-language 9P client and server library";
    homepage = "https://github.com/0intro/libixp";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ kovirobi ];
    platforms = with lib.platforms; unix;
    mainProgram = "ixpc";
  };
}
