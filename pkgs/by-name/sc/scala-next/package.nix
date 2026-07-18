{ fetchurl, scala }:

scala.bare.overrideAttrs (oldAttrs: {
  pname = "scala-next";
  version = "3.8.3";

  src = fetchurl {
    inherit (oldAttrs.src) url;
    hash = "sha256-/2LoJ+seoXgT2X5f1eDSaQEQeHFz/h4eQ9na3MNUL6c=";
  };
})
