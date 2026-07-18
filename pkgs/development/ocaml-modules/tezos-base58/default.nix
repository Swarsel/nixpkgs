{
  lib,
  fetchurl,
  buildDunePackage,
  digestif,
  fmt,
  zarith,
}:

buildDunePackage rec {
  pname = "tezos-base58";
  version = "1.0.0";

  src = fetchurl {
    url = "https://github.com/tarides/tezos-base58/releases/download/${version}/${pname}-${version}.tbz";
    sha256 = "14w2pff5dy6mxnz588pxaf2k8xpkd51sbsys065wr51kbv1f36da";
  };

  propagatedBuildInputs = [
    zarith
    digestif
    fmt
  ];

  duneVersion = "3";
  minimalOCamlVersion = "4.08";

  meta = {
    description = "Base58 encoding for Tezos";
    homepage = "https://github.com/tarides/tezos-base58/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bezmuth ];
  };

}
