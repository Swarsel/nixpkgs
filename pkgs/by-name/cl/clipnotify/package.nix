{
  lib,
  stdenv,
  fetchFromGitHub,
  libx11,
  libxfixes,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "clipnotify";
  version = "unstable-2018-02-20";

  src = fetchFromGitHub {
    owner = "cdown";
    repo = "clipnotify";
    rev = "9cb223fbe494c5b71678a9eae704c21a97e3bddd";
    sha256 = "1x9avjq0fgw0svcbw6b6873qnsqxbacls9sipmcv86xia4bxh8dn";
  };

  buildInputs = [
    libx11
    libxfixes
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp clipnotify $out/bin
  '';

  meta = {
    inherit (finalAttrs.src.meta) homepage;
    description = "Notify on new X clipboard events";
    license = lib.licenses.publicDomain;
    maintainers = with lib.maintainers; [ jb55 ];
    mainProgram = "clipnotify";
  };
})
