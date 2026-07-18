{
  lib,
  stdenv,
  fetchFromGitHub,
  avogadrolibs,
  cmake,
  eigen,
  hdf5,
  jkqtplotter,
  mesa,
  openbabel,
  qt6,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "avogadro2";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "OpenChemistry";
    repo = "avogadroapp";
    rev = finalAttrs.version;
    hash = "sha256-+/NZwLRrbrfrQqxLqgiqZk6324BGoN+qRfOq7G+UIBE=";
  };

  nativeBuildInputs = [
    cmake
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    avogadrolibs
    eigen
    hdf5
    jkqtplotter
    qt6.qttools
  ];

  propagatedBuildInputs = [ openbabel ];

  postUnpack =
    let
      avogadroI18N = fetchFromGitHub {
        hash = "sha256-5eiOFJ5tbS+HFbnLbc6sjk62BvXDMQYpPsB4xFpVWXM=";
        owner = "OpenChemistry";
        repo = "avogadro-i18n";
        tag = finalAttrs.version;
      };
    in
    ''
      cp -r ${avogadroI18N} avogadro-i18n
    '';

  qtWrapperArgs = [ "--prefix PATH : ${lib.getBin openbabel}/bin" ];

  meta = {
    inherit (mesa.meta) platforms;
    description = "Molecule editor and visualizer";
    homepage = "https://github.com/OpenChemistry/avogadroapp";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ sheepforce ];
    mainProgram = "avogadro2";
  };
})
