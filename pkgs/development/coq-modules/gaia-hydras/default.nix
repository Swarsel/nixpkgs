{
  lib,
  coq,
  gaia,
  hydra-battles,
  mathcomp,
  mathcomp-zify,
  mkCoqDerivation,
  version ? null,
}:

mkCoqDerivation {
  inherit version;
  pname = "gaia-hydras";

  propagatedBuildInputs = [
    hydra-battles
    gaia
    mathcomp-zify
  ];

  defaultVersion =
    with lib.versions;
    lib.switch
      [ coq.coq-version mathcomp.version ]
      [
        {
          cases = [
            (range "8.13" "8.16")
            (range "1.12.0" "1.18.0")
          ];

          out = "0.9";
        }
        {
          cases = [
            (range "8.13" "8.14")
            (range "1.12.0" "1.18.0")
          ];

          out = "0.5";
        }
      ]
      null;

  release."0.5".hash = "sha256:121pcbn6v59l0c165ha9n00whbddpy11npx2y9cn7g879sfk2nqk";
  release."0.6".hash = "sha256:1dri4sisa7mhclf8w4kw7ixs5zxm8xyjr034r1377p96rdk3jj0j";
  release."0.9".hash = "sha256-wlK+154owQD/03FB669KCjyQlL2YOXLCi0KLSo0DOwc=";
  releaseRev = (v: "v${v}");
  repo = "hydra-battles";
  useDune = true;

  meta = {
    description = "Comparison between ordinals in Gaia and Hydra battles";

    longDescription = ''
      The Gaia and Hydra battles projects develop different notions of ordinals.
      This development bridges the different notions.
    '';

    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ Zimmi48 ];
    platforms = lib.platforms.unix;
  };
}
