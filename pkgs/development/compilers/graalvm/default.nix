{
  lib,
  config,
  pkgs,
}:

lib.makeScope pkgs.newScope (
  self:
  {
    buildGraalvm = self.callPackage ./community-edition/buildGraalvm.nix;
    buildGraalvmProduct = self.callPackage ./community-edition/buildGraalvmProduct.nix;
    graaljs = self.callPackage ./community-edition/graaljs { };
    graalnodejs = self.callPackage ./community-edition/graalnodejs { };
    graalpy = self.callPackage ./community-edition/graalpy { };
    graalvm-ce = self.callPackage ./community-edition/graalvm-ce { };
    graalvm-ce-musl = self.callPackage ./community-edition/graalvm-ce { useMusl = true; };
    graalvm-oracle = self.graalvm-oracle_25;
    graalvm-oracle_17 = self.callPackage ./graalvm-oracle { version = "17"; };

    graalvm-oracle_25 = (self.callPackage ./graalvm-oracle { version = "25"; }).overrideAttrs (prev: {
      autoPatchelfIgnoreMissingDeps = [ "libonnxruntime.so.1" ];
    });

    truffleruby = self.callPackage ./community-edition/truffleruby { };
  }
  // lib.optionalAttrs config.allowAliases {
    graalvm-oracle_22 = throw "GraalVM 22 is EOL, use a newer version instead";
    graalvm-oracle_23 = throw "GraalVM 23 is EOL, use a newer version instead";
    graalvm-oracle_24 = throw "GraalVM 24 is EOL, use a newer version instead";
    graalvm-oracle_25-ea = throw "GraalVM 25-ea has been replaced by GraalVM 25";
  }
)
