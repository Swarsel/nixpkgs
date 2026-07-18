{
  lib,
  coq,
  iris,
  mkCoqDerivation,
  version ? null,
}:

mkCoqDerivation {
  inherit version;
  pname = "iris-named-props";
  propagatedBuildInputs = [ iris ];

  defaultVersion =
    with lib.versions;
    lib.switch coq.version [
      {
        case = range "8.16" "8.19";
        out = "2023-08-14";
      }
    ] null;

  owner = "tchajed";
  release."2023-08-14".hash = "sha256-gu9qOdHO0qJ2B9Y9Vf66q08iNJcfuECJO66fizFB08g=";
  release."2023-08-14".rev = "ca1871dd33649f27257a0fbf94076acc80ecffbc";

  meta = {
    description = "Named props for Iris";
    maintainers = with lib.maintainers; [ ineol ];
  };
}
