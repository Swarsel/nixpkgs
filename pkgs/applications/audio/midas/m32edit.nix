{ callPackage, ... }@args:

callPackage ./generic.nix (
  args
  // rec {
    version = "4.4.1";
    brand = "Midas";
    hash = "sha256-cEva2Brxo7zm3qppO+BtYIlUqV9t69j+8f6g94C4i3c=";
    homepage = "https://www.midasconsoles.com/en/products/0603-AEO";
    type = "M32";
    url = "https://cdn-media.empowertribe.com/9ba5bed1bc7a427cb96cef8aeb49f097/${type}-Edit_LINUX_${version}.tar.gz";
  }
)
