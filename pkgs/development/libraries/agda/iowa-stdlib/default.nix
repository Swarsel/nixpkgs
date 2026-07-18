{
  lib,
  fetchFromGitHub,
  mkDerivation,
}:

mkDerivation rec {
  pname = "iowa-stdlib";
  version = "1.5.0";

  src = fetchFromGitHub {
    owner = "cedille";
    repo = "ial";
    rev = "v${version}";
    sha256 = "0dlis6v6nzbscf713cmwlx8h9n2gxghci8y21qak3hp18gkxdp0g";
  };

  buildPhase = ''
    patchShebangs find-deps.sh
    make
  '';

  libraryFile = "";
  libraryName = "IAL-1.3";

  meta = {
    description = "Agda standard library developed at Iowa";
    homepage = "https://github.com/cedille/ial";
    license = lib.licenses.free;

    maintainers = with lib.maintainers; [
      alexarice
      turion
    ];

    platforms = lib.platforms.unix;
    # broken since Agda 2.6.1
    broken = true;
  };
}
