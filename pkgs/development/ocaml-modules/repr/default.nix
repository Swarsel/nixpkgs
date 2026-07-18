{
  lib,
  fetchurl,
  base64,
  buildDunePackage,
  either,
  fmt,
  jsonm,
  optint,
  # This version constraint strictly applies only to ppx_repr,
  # but is enforced here to get a consistent package set
  # (with repr and ppx_repr at the same version)
  ppxlib,
  uutf,
  version ? if lib.versionAtLeast ppxlib.version "0.36" then "0.8.0" else "0.7.0",
}:

buildDunePackage {
  inherit version;
  pname = "repr";

  src = fetchurl {
    url = "https://github.com/mirage/repr/releases/download/${version}/repr-${version}.tbz";

    hash =
      {
        "0.7.0" = "sha256-itrJ/oW/ig4g7raBDXIW6Y4bf02b05nmG7ECSs4lAaw=";
        "0.8.0" = "sha256-FyhCO4sCCPmwMq0+Bd2WpDuSzXZBb5FG45TwsLoTM0c=";
      }
      ."${version}";
  };

  propagatedBuildInputs = [
    base64
    either
    fmt
    jsonm
    uutf
    optint
  ];

  meta = {
    description = "Dynamic type representations. Provides no stability guarantee";
    homepage = "https://github.com/mirage/repr";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ sternenseemann ];
  };
}
