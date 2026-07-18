{ callPackage, ... }@args:

callPackage ./generic.nix (
  args
  // {
    pname = "vm";
    version = "0.14.0";
    description = "Programmable virtual machine LV2 plugin";
    sha256 = "013gq7jn556nkk1nq6zzh9nmp3fb36jd7ndzvyq3qryw7khzkagc";
  }
)
