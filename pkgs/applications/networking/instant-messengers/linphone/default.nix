{
  lib,
  generateSplicesForMkScope,
  makeScopeWithSplicing',
}:
makeScopeWithSplicing' {
  extra = self: {
    linphoneSdkHash = "sha256-mdJDCuCaZlcQ92P6oMgH/8iWgm8hGz8gTVUilC+yaSU=";
    linphoneSdkVersion = "5.4.85";
    mkLinphoneDerivation = self.mk-linphone-derivation;
  };

  f =
    self:
    let
      packages = lib.filterAttrs (name: value: value == "directory") (builtins.readDir ./.);
    in
    lib.mapAttrs (name: value: self.callPackage ./${name} { }) packages;

  otherSplices = generateSplicesForMkScope "linphonePackages";
}
