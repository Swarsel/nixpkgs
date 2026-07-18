{
  lib,
  stdenv,
  chicken,
  makeWrapper,
}:
{
  src,
  buildInputs ? [ ],
  chickenInstallFlags ? [ ],
  cscOptions ? [ ],
  name ? "${args.pname}-${args.version}",
  ...
}@args:

let
  libPath = "${chicken}/var/lib/chicken/${toString chicken.binaryVersion}/";
  overrides = import ./overrides.nix;
  baseName = lib.getName name;
  override = if builtins.hasAttr baseName overrides then builtins.getAttr baseName overrides else { };
in
stdenv.mkDerivation (
  {
    nativeBuildInputs = [ makeWrapper ];
    buildInputs = [ chicken ];
    propagatedBuildInputs = buildInputs;

    env = {
      CHICKEN_INSTALL_PREFIX = "$out";
      CHICKEN_REPOSITORY = libPath;
      CSC_OPTIONS = lib.concatStringsSep " " cscOptions;
    }
    // (args.env or { });

    installPhase = ''
      runHook preInstall

      chicken-install -p $out ${lib.concatStringsSep " " chickenInstallFlags}

      for f in $out/bin/*
      do
        wrapProgram $f \
          --set CHICKEN_REPOSITORY $CHICKEN_REPOSITORY \
          --prefix CHICKEN_REPOSITORY_EXTRA : "$out/lib/chicken/${toString chicken.binaryVersion}/:$CHICKEN_REPOSITORY_EXTRA" \
          --prefix CHICKEN_INCLUDE_PATH \; "$CHICKEN_INCLUDE_PATH;$out/share/" \
          --prefix PATH : "$out/bin:${chicken}/bin:$CHICKEN_REPOSITORY_EXTRA:$CHICKEN_REPOSITORY"
      done

      runHook postInstall
    '';

    name = "chicken-${name}";

    meta = {
      inherit (chicken.meta) platforms;
    }
    // args.meta or { };
  }
  // (removeAttrs args [
    "name"
    "buildInputs"
    "meta"
  ])
  // override
)
