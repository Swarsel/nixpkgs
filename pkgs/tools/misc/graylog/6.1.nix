{ lib, callPackage, ... }:
let
  buildGraylog = callPackage ./graylog.nix { };
in
buildGraylog {
  version = "6.1.8";
  hash = "sha256-omyV4BSY9SWDFyLcQCr0+LcjRecw9C1HtvsnCJrZX1U=";
  license = lib.licenses.sspl;
  maintainers = with lib.maintainers; [ bbenno ];
}
