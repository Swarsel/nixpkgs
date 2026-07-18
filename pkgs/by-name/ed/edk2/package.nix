{
  lib,
  stdenv,
  fetchFromGitHub,
  applyPatches,
  bc,
  buildPackages,
  libuuid,
  nixosTests,
  writeScript,
}:

let
  pythonEnv = buildPackages.python3.withPackages (ps: [ ps.tkinter ]);

  targetArch =
    if stdenv.hostPlatform.isi686 then
      "IA32"
    else if stdenv.hostPlatform.isx86_64 then
      "X64"
    else if stdenv.hostPlatform.isAarch32 then
      "ARM"
    else if stdenv.hostPlatform.isAarch64 then
      "AARCH64"
    else if stdenv.hostPlatform.isRiscV64 then
      "RISCV64"
    else if stdenv.hostPlatform.isLoongArch64 then
      "LOONGARCH64"
    else
      throw "Unsupported architecture";

  # The toolchain definition uses different variables for different architectures.
  targetPrefixes = lib.genAttrs [ "GCC_BIN" "GCC_${targetArch}_PREFIX" ] (
    lib.const stdenv.cc.targetPrefix
  );
in

stdenv.mkDerivation (finalAttrs: {
  pname = "edk2";
  version = "202605";

  src = applyPatches {
    name = "edk2-${finalAttrs.version}-unvendored-src";

    patches = [
      ./fix-cross-compilation-antlr-dlg.patch
    ];

    postPatch = ''
      # de-vendor OpenSSL
      rm -r CryptoPkg/Library/OpensslLib/openssl
      mkdir -p CryptoPkg/Library/OpensslLib/openssl
      (
      cd CryptoPkg/Library/OpensslLib/openssl
      tar --strip-components=1 -xf ${buildPackages.openssl_3_5.src}

      # Apply OpenSSL patches.
      ${lib.pipe buildPackages.openssl_3_5.patches [
        (builtins.filter (
          patch:
          !builtins.elem (baseNameOf patch) [
            # Exclude patches not required in this context.
            "nix-ssl-cert-file.patch"
            "openssl-disable-kernel-detection.patch"
            "use-etc-ssl-certs-darwin.patch"
            "use-etc-ssl-certs.patch"
          ]
        ))
        (map (patch: "patch -p1 < ${patch}\n"))
        lib.concatStrings
      ]}
      )

      # enable compilation using Clang
      # https://bugzilla.tianocore.org/show_bug.cgi?id=4620
      substituteInPlace BaseTools/Conf/tools_def.template --replace-fail \
        'DEFINE CLANGPDB_WARNING_OVERRIDES    = ' \
        'DEFINE CLANGPDB_WARNING_OVERRIDES    = -Wno-unneeded-internal-declaration '
    '';

    src = finalAttrs.srcWithVendoring;
  };

  strictDeps = true;
  nativeBuildInputs = [ pythonEnv ];
  makeFlags = [ "--directory=BaseTools" ];

  env = {
    NIX_CFLAGS_COMPILE =
      "-Wno-return-type"
      + lib.optionalString (stdenv.cc.isGNU) " -Wno-error=stringop-truncation"
      + lib.optionalString (stdenv.hostPlatform.isDarwin) " -Wno-error=macro-redefined";

    PYTHON_COMMAND = lib.getExe pythonEnv;
  }
  // targetPrefixes;

  installPhase = ''
    runHook preInstall

    mkdir -vp $out
    mv -v BaseTools $out
    mv -v edksetup.sh $out
    # patchShebangs fails to see these when cross compiling
    for i in $out/BaseTools/BinWrappers/PosixLike/*; do
      chmod +x "$i"
      patchShebangs --build "$i"
    done

    runHook postInstall
  '';

  depsBuildBuild = [
    buildPackages.stdenv.cc
    buildPackages.bash
  ];

  depsHostHost = [ libuuid ];
  enableParallelBuilding = true;

  hardeningDisable = [
    "format"
    "fortify"
  ];

  srcWithVendoring = fetchFromGitHub {
    fetchSubmodules = true;
    hash = "sha256-sUqLocdX7lxN2pEdn84Cjh8pOzYqIeKqO144XhwKA30=";
    owner = "tianocore";
    repo = "edk2";
    tag = "edk2-stable${finalAttrs.version}";
  };

  passthru = {
    mkDerivation =
      projectDscPath: attrsOrFun:
      stdenv.mkDerivation (
        finalAttrsInner:
        let
          attrs = lib.toFunction attrsOrFun finalAttrsInner;
          buildType = attrs.buildType or (if stdenv.hostPlatform.isDarwin then "CLANGPDB" else "GCC");
        in
        {
          inherit (finalAttrs) src;
          strictDeps = true;

          nativeBuildInputs = [
            bc
            pythonEnv
          ]
          ++ attrs.nativeBuildInputs or [ ];

          buildPhase = ''
            runHook preBuild
            build -a ${targetArch} -b ${attrs.buildConfig or "RELEASE"} -t ${buildType} -p ${projectDscPath} -n $NIX_BUILD_CORES $buildFlags
            runHook postBuild
          '';

          installPhase = ''
            runHook preInstall
            mv -v Build/*/* $out
            runHook postInstall
          '';

          configurePhase = ''
            runHook preConfigure
            export WORKSPACE="$PWD"
            . ${buildPackages.edk2}/edksetup.sh BaseTools
            runHook postConfigure
          '';

          depsBuildBuild = [ buildPackages.stdenv.cc ] ++ attrs.depsBuildBuild or [ ];

          prePatch = ''
            rm -rf BaseTools
            ln -sv ${buildPackages.edk2}/BaseTools BaseTools
          '';
        }
        // removeAttrs attrs [
          "nativeBuildInputs"
          "depsBuildBuild"
          "env"
        ]
        // {
          env = targetPrefixes // (attrs.env or { });
        }
      );

    # exercise a channel blocker
    tests = {
      systemdBootExtraEntries = nixosTests.systemd-boot.extraEntries;
      uefiUsb = nixosTests.boot.uefiCdrom;
    };

    updateScript = writeScript "update-edk2" ''
      #!/usr/bin/env nix-shell
      #!nix-shell -i bash -p common-updater-scripts coreutils gnused
      set -eu -o pipefail
      version="$(list-git-tags --url="${finalAttrs.srcWithVendoring.url}" |
                 sed -E --quiet 's/^edk2-stable([0-9\\.]+)$/\1/p' |
                 sort --reverse --numeric-sort |
                 head -n 1)"
      if [[ "x$UPDATE_NIX_OLD_VERSION" != "x$version" ]]; then
          update-source-version --source-key=srcWithVendoring \
              "$UPDATE_NIX_ATTR_PATH" "$version"
      fi
    '';
  };

  meta = {
    description = "Intel EFI development kit";
    homepage = "https://github.com/tianocore/tianocore.github.io/wiki/EDK-II/";
    changelog = "https://github.com/tianocore/edk2/releases/tag/edk2-stable${finalAttrs.version}";
    license = lib.licenses.bsd2;
    maintainers = [ lib.maintainers.mjoerg ];
    platforms = with lib.platforms; aarch64 ++ arm ++ i686 ++ x86_64 ++ loongarch64 ++ riscv64;
  };
})
