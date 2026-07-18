{
  lib,
  stdenv,
  buildFreebsd,
  buildPackages,
  fetchgit,
  patchesRoot,
  sourceData,
  stdenvNoCC,
  versionData,
  writeText,
}:

self:

lib.packagesFromDirectoryRecursive {
  callPackage = self.callPackage;
  directory = ./pkgs;
}
// {
  inherit sourceData patchesRoot versionData;
  # Keep the crawled portion of Nixpkgs finite.
  buildFreebsd = lib.dontRecurseIntoAttrs buildFreebsd;

  # The manual callPackages below should in principle be unnecessary, but are
  # necessary. See note in ../netbsd/default.nix
  compat = self.callPackage ./pkgs/compat/package.nix {
    inherit stdenv;
    inherit (buildFreebsd) makeMinimal;
  };

  compatIfNeeded = lib.optional self.compatIsNeeded self.compat;
  compatIsNeeded = !stdenvNoCC.hostPlatform.isFreeBSD;

  csu = self.callPackage ./pkgs/csu.nix {
    inherit (buildFreebsd) makeMinimal install gencat;
    inherit (self) include;
  };

  freebsd-lib = import ./lib {
    inherit lib writeText;

    version = lib.concatStringsSep "." (
      map toString (
        lib.filter (x: x != null) [
          self.versionData.major
          self.versionData.minor
          self.versionData.patch or null
        ]
      )
    );
  };

  i18n = self.callPackage ./pkgs/i18n.nix { inherit (buildFreebsd) mkcsmapper mkesdb; };
  include = self.callPackage ./pkgs/include/package.nix { inherit (buildFreebsd) rpcgen mtree; };

  install = self.callPackage ./pkgs/install.nix {
    inherit (buildFreebsd) makeMinimal;
    inherit (self) libmd libnetbsd;
  };

  libc = self.callPackage ./pkgs/libc/package.nix {
    inherit (self) libcMinimal librpcsvc libelf;
  };

  libcMinimal = self.callPackage ./pkgs/libcMinimal.nix {
    inherit (buildFreebsd)
      rpcgen
      gencat
      ;

    inherit (buildPackages)
      flex
      byacc
      ;
  };

  libelf = self.callPackage ./pkgs/libelf.nix { inherit (buildPackages) m4; };
  libmd = self.callPackage ./pkgs/libmd.nix { inherit (buildFreebsd) makeMinimal; };
  libnetbsd = self.callPackage ./pkgs/libnetbsd/package.nix { inherit (buildFreebsd) makeMinimal; };

  librpcsvc = self.callPackage ./pkgs/librpcsvc.nix {
    inherit (buildFreebsd) rpcgen;
  };

  makeMinimal = self.callPackage ./pkgs/makeMinimal.nix { inherit (self) make; };

  mkDerivation = self.callPackage ./pkgs/mkDerivation.nix {
    inherit stdenv;

    inherit (buildFreebsd)
      freebsdSetupHook
      makeMinimal
      install
      tsort
      lorder
      ;
  };

  mtree = self.callPackage ./pkgs/mtree.nix { inherit (self) libnetbsd libmd; };

  ports = fetchgit {
    rev = "dde3b2b456c3a4bdd217d0bf3684231cc3724a0a";
    sha256 = "BpHqJfnGOeTE7tkFJBx0Wk8ryalmf4KNTit/Coh026E=";
    url = "https://git.FreeBSD.org/ports.git";
  };

  rtld-elf = self.callPackage ./pkgs/rtld-elf.nix {
    inherit (buildFreebsd) rpcgen;
    inherit (buildPackages) flex byacc;
  };

  tsort = self.callPackage ./pkgs/tsort.nix { inherit (buildFreebsd) makeMinimal install; };
}
