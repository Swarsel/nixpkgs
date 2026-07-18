{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "clolcat";
  version = "1.1";

  src = fetchFromGitHub {
    owner = "IchMageBaume";
    repo = "clolcat";
    rev = finalAttrs.version;
    sha256 = "sha256-fLa239dwEXe4Jyy5ntgfU9V0h5wrBsvq6/s2HCis7Sc=";
  };

  makeFlags = [ "DESTDIR=$(out)/bin" ];
  preInstall = "mkdir -p $out/bin";

  meta = {
    description = "Much faster lolcat";
    homepage = "https://github.com/IchMageBaume/clolcat";
    license = lib.licenses.wtfpl;
    maintainers = [ lib.maintainers.felipeqq2 ];
    platforms = lib.platforms.all;
    mainProgram = "clolcat";
  };
})
