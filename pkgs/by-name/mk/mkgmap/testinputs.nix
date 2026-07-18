{ fetchurl }:
let
  fetchTestInput =
    { hash, res }:
    fetchurl {
      inherit hash;
      name = builtins.replaceStrings [ "/" ] [ "__" ] res;
      url = "https://www.mkgmap.org.uk/testinput/${res}";
    };
in
[
  (fetchTestInput {
    hash = "sha256-Oze0loYeIZQ3w1cB2HeXFPDgzuU4s+T78k96BY+hGuU=";
    res = "osm/lon1.osm.gz";
  })
  (fetchTestInput {
    hash = "sha256-0zVSP5yTmJUxYbXxFqBAn0pb08L3Z3gwilsKYeV8tkk=";
    res = "osm/uk-test-1.osm.gz";
  })
  (fetchTestInput {
    hash = "sha256-ROMgljyxYD7bwH1nXqoUZ1H8gM9e9dpoKCHO1xgGvBY=";
    res = "osm/uk-test-2.osm.gz";
  })
  (fetchTestInput {
    hash = "sha256-Ay7o1w2TpOpIqPGrLuIcMYtK8MDN0GbkSkX7IvByeKM=";
    res = "osm/is-in-samples.osm";
  })
  (fetchTestInput {
    hash = "sha256-Ql5tdz3TMcRl/8k20Jek6g3W92/itpnqw24wgj7I07c=";
    res = "mp/test1.mp";
  })
  (fetchTestInput {
    hash = "sha256-mBxOZyJlHZJ/hEmqqO4eVfoORGzoF8S/2jpgQJJ/uPI=";
    res = "img/63240001.img";
  })
  (fetchTestInput {
    hash = "sha256-Lijc6+JKaYq1xL64wcAnEnPhXOmWMjA9fZkaHif3O4o=";
    res = "img/63240002.img";
  })
  (fetchTestInput {
    hash = "sha256-4Wu1svN474O145ONM45pMR3GjtQpII00VGjiaTbur6Y=";
    res = "img/63240003.img";
  })
  (fetchTestInput {
    hash = "sha256-9nU9oczkWS1Cqc8SyQmo1QaYK+6jr+Wq+PoQ95YBC5o=";
    res = "hgt/N00W090.hgt.zip";
  })
  (fetchTestInput {
    hash = "sha256-PeT2PcbuPr+E4dzAme0TJqufbjNZn2wDkhiccCQncpQ=";
    res = "hgt/N00W091.hgt.zip";
  })
  (fetchTestInput {
    hash = "sha256-UqPnJmY51YamU/EGbCQVFdoh890HpFN//XadC3PS7zM=";
    res = "hgt/S01W090.hgt.zip";
  })
  (fetchTestInput {
    hash = "sha256-dvHxDgjKhmkQSmPPW8CtbsQWYtoYYuk6dTUlEtXAqHw=";
    res = "hgt/S01W091.hgt.zip";
  })
  (fetchTestInput {
    hash = "sha256-tjjYMxW6lWvWONoWFwTjHn+EhJ7OmcjGwVvM3t4J6GA=";
    res = "hgt/S02W090.hgt.zip";
  })
  (fetchTestInput {
    hash = "sha256-uVUKhM5eIS/STGxwgzDcXITRTqvILtHrS8mmXVB7l9c=";
    res = "hgt/S02W091.hgt.zip";
  })
]
