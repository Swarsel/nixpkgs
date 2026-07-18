{
  lib,
  doxygen,
  mkMesonDerivation,
  # Configuration Options
  version,
}:

mkMesonDerivation (finalAttrs: {
  inherit version;
  pname = "nix-external-api-docs";

  nativeBuildInputs = [
    doxygen
  ];

  preConfigure = ''
    chmod u+w ./.version
    echo ${finalAttrs.version} > ./.version
  '';

  postInstall = ''
    mkdir -p ''${!outputDoc}/nix-support
    echo "doc external-api-docs $out/share/doc/nix/external-api/html" >> ''${!outputDoc}/nix-support/hydra-build-products
  '';

  workDir = ./.;

  meta = {
    platforms = lib.platforms.all;
  };
})
