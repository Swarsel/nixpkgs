{
  lib,
  stdenv,
  alsa-lib,
  autoPatchelfHook,
  buildPackages,
  darwin,
  fetchzip,
  gtk2,
  gtk3,
  libgbm,
  makeShellWrapper,
  nss,
  udev,
  unzip,
}:

let
  availableBinaries = {
    aarch64-darwin = {
      hash = "sha256-8qvMsC+tRKK12jC2r1A54kS/PZ6q+sErvLvTkse6Kn4=";
      platform = "darwin-arm64";
    };

    aarch64-linux = {
      hash = "sha256-MIUVhWkfKN5056jhHN31h4dBcTHJI0iX+I2RbkNI80I=";
      platform = "linux-arm64";
    };

    x86_64-linux = {
      hash = "sha256-oCTpVD7W1NHWD0nJBrgtmWZZozbcJeAfr7mn/JjqdcM=";
      platform = "linux-x64";
    };
  };
  inherit (stdenv.hostPlatform) system;
  binary =
    availableBinaries.${system} or (throw "cypress: No binaries available for system ${system}");
  inherit (binary) platform hash;
in
stdenv.mkDerivation rec {
  pname = "cypress";
  version = "14.5.4";

  src = fetchzip {
    inherit hash;
    url = "https://cdn.cypress.io/desktop/${version}/${platform}/cypress.zip";
    stripRoot = !stdenv.hostPlatform.isDarwin;
  };

  nativeBuildInputs = [
    unzip
    makeShellWrapper
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    darwin.autoSignDarwinBinariesHook
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    autoPatchelfHook
    # override doesn't preserve splicing https://github.com/NixOS/nixpkgs/issues/132651
    # Has to use `makeShellWrapper` from `buildPackages` even though `makeShellWrapper` from the inputs is spliced because `propagatedBuildInputs` would pick the wrong one because of a different offset.
    (buildPackages.wrapGAppsHook3.override { makeWrapper = buildPackages.makeShellWrapper; })
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    nss
    alsa-lib
    gtk3
    libgbm
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/opt/cypress
    cp -vr * $out/opt/cypress/
    # Let's create the file binary_state ourselves to make the npm package happy on initial verification.
    # Cypress now verifies version by reading bin/resources/app/package.json
    mkdir -p $out/bin/resources/app
    printf '{"version":"%b"}' $version > $out/bin/resources/app/package.json
    # Cypress now looks for binary_state.json in bin
    echo '{"verified": true}' > $out/binary_state.json
    ${
      if stdenv.hostPlatform.isDarwin then
        ''
          ln -s $out/opt/cypress/Cypress.app/Contents/MacOS/Cypress $out/bin/cypress
        ''
      else
        ''
          ln -s $out/opt/cypress/Cypress $out/bin/cypress
        ''
    }
    runHook postInstall
  '';

  postFixup = lib.optionalString (!stdenv.hostPlatform.isDarwin) ''
    # exit with 1 after 25.05
    makeWrapper $out/opt/cypress/Cypress $out/bin/Cypress \
      --run 'echo "Warning: Use the lowercase cypress executable instead of the capitalized one."'
  '';

  # don't remove runtime deps
  dontPatchELF = true;
  runtimeDependencies = lib.optional stdenv.hostPlatform.isLinux (lib.getLib udev);

  passthru = {
    tests = {
      # We used to have a test here, but was removed because
      #  - it broke, and ofborg didn't fail https://github.com/NixOS/ofborg/issues/629
      #  - it had a large footprint in the repo; prefer RFC 92 or an ugly FOD fetcher?
      #  - the author switched away from cypress.
      # To provide a test once more, you may find useful information in
      # https://github.com/NixOS/nixpkgs/pull/223903
    };

    updateScript = ./update.sh;
  };

  meta = {
    description = "Fast, easy and reliable testing for anything that runs in a browser";
    homepage = "https://www.cypress.io";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];

    maintainers = with lib.maintainers; [
      tweber
      mmahut
      Crafter
      jonhermansen
    ];

    platforms = lib.attrNames availableBinaries;
    mainProgram = "Cypress";
  };
}
