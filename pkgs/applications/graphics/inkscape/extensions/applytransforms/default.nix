{
  lib,
  stdenv,
  fetchFromGitHub,
  python3,
}:

stdenv.mkDerivation {
  pname = "inkscape-applytransforms";
  version = "0.pre+unstable=2021-05-11";

  src = fetchFromGitHub {
    owner = "Klowner";
    repo = "inkscape-applytransforms";
    rev = "5b3ed4af0fb66e399e686fc2b649b56db84f6042";
    sha256 = "XWwkuw+Um/cflRWjIeIgQUxJLrk2DLDmx7K+pMWvIlI=";
  };

  doCheck = true;

  nativeCheckInputs = [
    python3.pkgs.inkex
    python3.pkgs.pytestCheckHook
  ];

  installPhase = ''
    runHook preInstall

    install -Dt "$out/share/inkscape/extensions" *.inx *.py

    runHook postInstall
  '';

  dontBuild = true;

  meta = {
    description = "Inkscape extension which removes all matrix transforms by applying them recursively to shapes";
    homepage = "https://github.com/Klowner/inkscape-applytransforms";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ jtojnar ];
    platforms = lib.platforms.all;
  };
}
