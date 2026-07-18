{
  lib,
  doxygen,
  mkMesonDerivation,
  # Configuration Options
  version,
}:

mkMesonDerivation (finalAttrs: {
  inherit version;
  pname = "nix-internal-api-docs";

  nativeBuildInputs = [
    doxygen
  ];

  preConfigure = ''
    chmod u+w ./.version
    echo ${finalAttrs.version} > ./.version
  '';

  postInstall = ''
    mkdir -p ''${!outputDoc}/nix-support
    echo "doc internal-api-docs $out/share/doc/nix/internal-api/html" >> ''${!outputDoc}/nix-support/hydra-build-products
  '';

  workDir = ./.;

  meta = {
    platforms = lib.platforms.all;
  };
})
