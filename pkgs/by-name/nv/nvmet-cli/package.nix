{
  lib,
  fetchurl,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "nvmet-cli";
  version = "0.7";

  src = fetchurl {
    url = "ftp://ftp.infradead.org/pub/nvmetcli/nvmetcli-${finalAttrs.version}.tar.gz";
    sha256 = "051y1b9w46azy35118154c353v3mhjkdzh6h59brdgn5054hayj2";
  };

  buildInputs = with python3Packages; [ nose2 ];
  propagatedBuildInputs = with python3Packages; [ configshell-fb ];
  # This package requires the `nvmet` kernel module to be loaded for tests.
  doCheck = false;
  format = "setuptools";

  meta = {
    description = "NVMe target CLI";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ hoverbear ];
    platforms = lib.platforms.linux;
    mainProgram = "nvmetcli";
  };
})
