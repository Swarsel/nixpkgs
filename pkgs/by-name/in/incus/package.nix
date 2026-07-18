import ./generic.nix {
  version = "7.2.0";
  patches = fetchpatch2: [ ];
  vendorHash = "sha256-0lBMQXQEf+oYlvyoFV2VTpJbY+reavCJZQkzt9UbnaI=";
  hash = "sha256-GVCC0nV5Ghd9BroVC4ysqiTIQ3AtXIJ+EG6VbJVQBB4=";

  nixUpdateExtraArgs = [
    "--override-filename=pkgs/by-name/in/incus/package.nix"
  ];
}
