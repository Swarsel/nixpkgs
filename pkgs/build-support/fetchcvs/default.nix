# example tags:
# date="2007-20-10"; (get the last version before given date)
# tag="<tagname>" (get version by tag name)
# If you don't specify neither one date="NOW" will be used (get latest)

{
  lib,
  cvs,
  openssh,
  stdenvNoCC,
}:

lib.makeOverridable (
  lib.fetchers.withNormalizedHash { } (
    {
      cvsRoot,
      module,
      outputHash,
      outputHashAlgo,
      date ? null,
      tag ? null,
    }:

    stdenvNoCC.mkDerivation {
      inherit outputHash outputHashAlgo;

      inherit
        cvsRoot
        module
        tag
        date
        ;

      nativeBuildInputs = [
        cvs
        openssh
      ];

      builder = ./builder.sh;
      name = "cvs-export";
      outputHashMode = "recursive";
    }
  )
)
