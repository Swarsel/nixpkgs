{ callPackage, ... }@args:

callPackage ./generic.nix (
  args
  // rec {
    version = "4.4.1";
    brand = "Behringer";
    hash = "sha256-HrSPDWnWF2s1U8Khj6VnLptPdcMVyTivewWAIIdArMc=";
    homepage = "https://www.behringer.com/en/products/0603-ACE";
    type = "X32";
    url = "https://cdn-media.empowertribe.com/23b991ede2e6473d916c7ac56f53d71d/${type}-Edit_LINUX_${version}.tar.gz";
  }
)
