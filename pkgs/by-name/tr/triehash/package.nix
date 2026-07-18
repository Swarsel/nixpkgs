{
  lib,
  stdenv,
  fetchFromGitHub,
  perlPackages,
}:

stdenv.mkDerivation {
  pname = "triehash";
  version = "0.3";

  src = fetchFromGitHub {
    owner = "julian-klode";
    repo = "triehash";
    rev = "debian/0.3-3";
    hash = "sha256-LxVcYj2WKHbhNu5x/DFkxQPOYrVkNvwiE/qcODq52Lc=";
  };

  postPatch = ''
    patchShebangs triehash.pl
  '';

  nativeBuildInputs = [
    perlPackages.perl
  ];

  installPhase = ''
    runHook preInstall

    install -d $out/bin $out/share/doc/triehash/ $out/share/triehash/
    install triehash.pl $out/bin/triehash
    install README.md $out/share/doc/triehash/
    cp -r tests/ $out/share/triehash/tests/

    runHook postInstall
  '';

  dontBuild = true;
  dontConfigure = true;

  meta = {
    description = "Order-preserving minimal perfect hash function generator";
    homepage = "https://github.com/julian-klode/triehash";
    license = with lib.licenses; mit;
    maintainers = [ ];
    platforms = perlPackages.perl.meta.platforms;
    mainProgram = "triehash";
  };
}
