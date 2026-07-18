{
  lib,
  stdenv,
  acpica-tools,
  buildEnv,
  coreutils,
  fetchgit,
  file,
  gnugrep,
  gnused,
  go,
  makeWrapper,
  openssl,
  pciutils,
  pkg-config,
  zlib,
}:

let
  version = "26.06";

  commonMeta = {
    description = "Various coreboot-related tools";
    homepage = "https://www.coreboot.org";

    license = with lib.licenses; [
      gpl2Only
      gpl2Plus
    ];

    maintainers = with lib.maintainers; [
      felixsinger
      jmbaur
    ];

    platforms = lib.platforms.linux;
  };

  generic =
    {
      pname,
      path ? "util/${pname}",
      ...
    }@args:
    stdenv.mkDerivation (
      finalAttrs:
      {
        inherit pname version;

        src = fetchgit {
          url = "https://review.coreboot.org/coreboot";
          rev = finalAttrs.version;
          hash = "sha256-rL9txaDXUzjkC2ioYmunoNq2+9rz9wpEJ7z3GZrqOH4=";
        };

        postPatch = ''
          substituteInPlace 3rdparty/vboot/Makefile --replace 'ar qc ' '$$AR qc '
          cd ${path}
          patchShebangs .
        '';

        makeFlags = [
          "INSTALL=install"
          "PREFIX=${placeholder "out"}"
        ];

        enableParallelBuilding = true;
        meta = commonMeta // args.meta;
      }
      // (removeAttrs args [ "meta" ])
    );

  utils = {
    acpidump-all = generic {
      pname = "acpidump-all";
      nativeBuildInputs = [ makeWrapper ];

      installPhase = ''
        runHook preInstall

        install -Dm755 acpidump-all $out/bin/acpidump-all

        runHook postInstall
      '';

      postFixup = ''
        wrapProgram $out/bin/acpidump-all \
          --set PATH ${
            lib.makeBinPath [
              coreutils
              acpica-tools
              gnugrep
              gnused
              file
            ]
          }
      '';

      dontBuild = true;
      path = "util/acpi";
      meta.description = "Walk through all ACPI tables with their addresses";
    };

    amdfwtool = generic {
      pname = "amdfwtool";
      nativeBuildInputs = [ pkg-config ];
      buildInputs = [ openssl ];

      installPhase = ''
        runHook preInstall

        install -Dm755 amdfwtool $out/bin/amdfwtool

        runHook postInstall
      '';

      meta.description = "Create AMD firmware combination";
    };

    cbfstool = generic {
      pname = "cbfstool";
      meta.description = "Management utility for CBFS formatted ROM images";
    };

    cbmem = generic {
      pname = "cbmem";
      meta.description = "Coreboot console log reader";
    };

    ectool = generic {
      pname = "ectool";
      preInstall = "mkdir -p $out/sbin";
      meta.description = "Dump the RAM of a laptop's Embedded/Environmental Controller (EC)";

      meta.platforms = [
        "x86_64-linux"
        "i686-linux"
      ];
    };

    ifdtool = generic {
      pname = "ifdtool";
      meta.description = "Extract and dump Intel Firmware Descriptor information";
    };

    intelmetool = generic {
      pname = "intelmetool";

      buildInputs = [
        pciutils
        zlib
      ];

      meta.description = "Dump interesting things about Management Engine";

      meta.platforms = [
        "x86_64-linux"
        "i686-linux"
      ];
    };

    # buildGoModule for some reason does not generate a binary
    intelp2m = generic {
      pname = "intelp2m";
      version = "2.5";
      nativeBuildInputs = [ go ];

      env = {
        GOCACHE = "/tmp/go-cache";
        VERSION = "2.5-${version}";
      };

      installPhase = ''
        runHook preInstall

        install -Dm755 intelp2m $out/bin/intelp2m

        runHook postInstall
      '';

      meta.description = "Convert the inteltool register dump to gpio.h with GPIO configuration for porting coreboot";
    };

    inteltool = generic {
      pname = "inteltool";

      buildInputs = [
        pciutils
        zlib
      ];

      meta.description = "Provides information about Intel CPU/chipset hardware configuration (register contents, MSRs, etc)";

      meta.platforms = [
        "x86_64-linux"
        "i686-linux"
      ];
    };

    msrtool = generic {
      pname = "msrtool";

      buildInputs = [
        pciutils
        zlib
      ];

      preConfigure = "export INSTALL=install";
      meta.description = "Dump chipset-specific MSR registers";

      meta.platforms = [
        "x86_64-linux"
        "i686-linux"
      ];
    };

    nvramtool = generic {
      pname = "nvramtool";
      meta.description = "Read and write coreboot parameters and display information from the coreboot table in CMOS/NVRAM";
      meta.mainProgram = "nvramtool";

      meta.platforms = [
        "x86_64-linux"
        "i686-linux"
      ];
    };

    superiotool = generic {
      pname = "superiotool";

      buildInputs = [
        pciutils
        zlib
      ];

      meta.description = "User-space utility to detect Super I/O of a mainboard and provide detailed information about the register contents of the Super I/O";

      meta.platforms = [
        "x86_64-linux"
        "i686-linux"
      ];
    };
  };

in
utils
// {
  coreboot-utils = (
    buildEnv {
      inherit version;
      pname = "coreboot-utils";
      postBuild = "rm -rf $out/sbin";
      paths = lib.filter (lib.meta.availableOn stdenv.hostPlatform) (lib.attrValues utils);
      meta = commonMeta;
    }
  );
}
