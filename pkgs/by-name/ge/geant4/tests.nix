{
  stdenv,
  cmake,
  geant4,
}:

{
  example_B1 = stdenv.mkDerivation {
    inherit (geant4) src;
    nativeBuildInputs = [ cmake ];
    buildInputs = [ geant4 ];
    doCheck = true;

    nativeCheckInputs = with geant4.data; [
      G4EMLOW
      G4ENSDFSTATE
      G4PARTICLEXS
      G4PhotonEvaporation
    ];

    checkPhase = ''
      runHook preCheck

      ./exampleB1 ../run2.mac

      runHook postCheck
    '';

    installPhase = ''
      runHook preInstall

      touch "$out"

      runHook postInstall
    '';

    name = "${geant4.name}-test-example_B1";

    prePatch = ''
      cd examples/basic/B1
    '';
  };
}
