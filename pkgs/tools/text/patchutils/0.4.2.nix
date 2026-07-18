{ callPackage, python3, ... }@args:

callPackage ./generic.nix (
  args
  // {
    version = "0.4.2";

    patches = [
      ./Make-grepdiff1-test-case-pcre-aware.patch
      ./getenv-signature.patch
    ];

    # for gitdiff
    extraBuildInputs = [ python3 ];
    sha256 = "sha256-iHWwll/jPeYriQ9s15O+f6/kGk5VLtv2QfH+1eu/Re0=";
  }
)
