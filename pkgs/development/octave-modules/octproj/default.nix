{
  lib,
  buildOctavePackage,
  fetchFromBitbucket,
  nix-update-script,
  proj, # >= 6.3.0
}:

buildOctavePackage rec {
  pname = "octproj";
  version = "3.1.0";

  src = fetchFromBitbucket {
    owner = "jgpallero";
    repo = "octproj";
    rev = "OctPROJ-${version}";
    sha256 = "sha256-0QDlpfqFTSndUPkOslugDBM0UBKiusZwKGFuDrco7X4=";
  };

  propagatedBuildInputs = [
    proj
  ];

  # The sed changes below allow for the package to be compiled.
  patchPhase = ''
    sed -i s/"error(errorText)"/"error(\"%s\", errorText)"/g src/*.cc
    sed -i s/"warning(errorText)"/"warning(\"%s\", errorText)"/g src/*.cc
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "OctPROJ-(.*)"
    ];
  };

  meta = {
    description = "GNU Octave bindings to PROJ library for cartographic projections and CRS transformations";
    homepage = "https://gnu-octave.github.io/packages/octproj/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ ravenjoad ];
  };
}
