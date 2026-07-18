# opinionated module that can be used to build nixos images with
# a dm-verity protected nix store
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.image.repart.verityStore;

  verityMatchKey = "store";

  # TODO: make these and other arch mappings available from systemd-lib for example
  partitionTypes = {
    usr =
      {
        "arm64" = "usr-arm64";
        "x86_64" = "usr-x86-64";
      }
      ."${pkgs.stdenv.hostPlatform.linuxArch}";

    usr-verity =
      {
        "arm64" = "usr-arm64-verity";
        "x86_64" = "usr-x86-64-verity";
      }
      ."${pkgs.stdenv.hostPlatform.linuxArch}";
  };

  verityHashCheck =
    pkgs.buildPackages.writers.writePython3Bin "assert_uki_repart_match.py"
      {
        flakeIgnore = [ "E501" ]; # ignores PEP8's line length limit of 79 (black defaults to 88 characters)
      }
      (
        builtins.replaceStrings
          [ "@NIX_STORE_VERITY@" ]
          [
            partitionTypes.usr-verity
          ]
          (builtins.readFile ./assert_uki_repart_match.py)
      );
in
{
  options.image.repart.verityStore = {
    enable = lib.mkEnableOption "building images with a dm-verity protected nix store";

    partitionIds = {
      esp = lib.mkOption {
        default = "00-esp";

        description = ''
          Specify the attribute name of the ESP.
        '';

        type = lib.types.str;
      };

      store = lib.mkOption {
        default = "20-store";

        description = ''
          Specify the attribute name of the store partition.
        '';

        type = lib.types.str;
      };

      store-verity = lib.mkOption {
        default = "10-store-verity";

        description = ''
          Specify the attribute name of the store's dm-verity hash partition.
        '';

        type = lib.types.str;
      };
    };

    ukiPath = lib.mkOption {
      default = "/EFI/Linux/${config.system.boot.loader.ukiFile}";
      defaultText = "/EFI/Linux/\${config.system.boot.loader.ukiFile}";

      description = ''
        Specify the location on the ESP where the UKI is placed.
      '';

      type = lib.types.str;
    };
  };

  config = lib.mkIf cfg.enable {
    boot.initrd = {
      supportedFilesystems = {
        ${config.image.repart.partitions.${cfg.partitionIds.store}.repartConfig.Format} =
          lib.mkDefault true;
      };

      systemd.dmVerity.enable = true;
    };

    fileSystems."/nix/store" = lib.mkDefault {
      options = [ "bind" ];
      device = "/usr/nix/store";
      fsType = "none";
    };

    image.repart.partitions = {
      # dm-verity hash partition
      ${cfg.partitionIds.store-verity}.repartConfig = {
        Label = lib.mkDefault "store-verity";
        Minimize = lib.mkDefault "best";
        Type = lib.mkDefault partitionTypes.usr-verity;
        Verity = "hash";
        VerityMatchKey = lib.mkDefault verityMatchKey;
      };

      # dm-verity data partition that contains the nix store
      ${cfg.partitionIds.store} = {
        repartConfig = {
          Format = lib.mkDefault "erofs";
          Label = lib.mkDefault "store";
          Minimize = lib.mkDefault "best";
          Type = lib.mkDefault partitionTypes.usr;
          Verity = "data";
          VerityMatchKey = lib.mkDefault verityMatchKey;
        };

        storePaths = [ config.system.build.toplevel ];
      };

    };

    system.build = {
      finalImage = lib.warn "system.build.finalImage has been renamed to system.build.image" config.system.build.image;

      # final system image that is created from the intermediate image by injecting the UKI from above
      image = lib.mkOverride 99 (
        (config.image.repart.image.override {
          # continue building with existing intermediate image
          createEmpty = false;
        }).overrideAttrs
          (
            finalAttrs: previousAttrs: {
              # add entry to inject UKI into ESP
              finalPartitions = lib.recursiveUpdate previousAttrs.finalPartitions {
                ${cfg.partitionIds.esp}.contents = {
                  "${cfg.ukiPath}".source = "${config.system.build.uki}/${config.system.boot.loader.ukiFile}";
                };
              };

              nativeBuildInputs = previousAttrs.nativeBuildInputs ++ [
                pkgs.buildPackages.systemdUkify
                verityHashCheck
                pkgs.buildPackages.jq
              ];

              preBuild = ''
                # check that we build the final image with the same intermediate image for
                # which the injected UKI was built by comparing the UKI cmdline with the repart output
                # of the intermediate image
                #
                # This is necessary to notice incompatible substitutions of
                # non-reproducible store paths, for example when working with distributed
                # builds, or when offline-signing the UKI.
                ukify --json=short inspect ${config.system.build.uki}/${config.system.boot.loader.ukiFile} \
                  | assert_uki_repart_match.py "${config.system.build.intermediateImage}/repart-output.json"

                # copy the uncompressed intermediate image, so that systemd-repart picks it up
                cp -v ${config.system.build.intermediateImage}/${config.image.baseName}.raw .
                chmod +w ${config.image.baseName}.raw
              '';

              # replace "TBD" with the original roothash values
              preInstall = ''
                mv -v repart-output{.json,_orig.json}

                jq --slurp --indent -1 \
                  '.[0] as $intermediate | .[1] as $final
                    | $intermediate | map(select(.roothash != null) | { "uuid":.uuid,"roothash":.roothash }) as $uuids
                    | $final + $uuids
                    | group_by(.uuid)
                    | map(add)
                    | sort_by(.offset)' \
                      ${config.system.build.intermediateImage}/repart-output.json \
                      repart-output_orig.json \
                  > repart-output.json

                rm -v repart-output_orig.json
              '';
            }
          )
      );

      # intermediate system image without ESP
      intermediateImage =
        (config.image.repart.image.override {
          # always disable compression for the intermediate image
          compression.enable = false;
        }).overrideAttrs
          (
            _: previousAttrs: {
              # make it easier to identify the intermediate image in build logs
              name =
                if previousAttrs ? pname then
                  "${previousAttrs.pname}-${previousAttrs.version}-intermediate"
                else
                  "${previousAttrs.name}-intermediate";

              # do not prepare the ESP, this is done in the final image
              systemdRepartFlags = previousAttrs.systemdRepartFlags ++ [ "--defer-partitions=esp" ];
            }
          );

      # UKI with embedded usrhash from intermediateImage
      uki =
        let
          inherit (config.system.boot.loader) ukiFile;
          cmdline = "init=${config.system.build.toplevel}/init ${toString config.boot.kernelParams}";
        in
        # override the default UKI
        lib.mkOverride 99 (
          pkgs.runCommand ukiFile
            {
              nativeBuildInputs = [
                pkgs.buildPackages.jq
                pkgs.buildPackages.systemdUkify
              ];
            }
            ''
              mkdir -p $out

              # Extract the usrhash from the output of the systemd-repart invocation for the intermediate image.
              usrhash=$(jq -r \
                '.[] | select(.type=="${partitionTypes.usr-verity}") | .roothash' \
                ${config.system.build.intermediateImage}/repart-output.json
              )

              # Build UKI with the embedded usrhash.
              ukify build \
                  --config=${config.boot.uki.configFile} \
                  --cmdline="${cmdline} usrhash=$usrhash" \
                  --output="$out/${ukiFile}"
            ''
        );
    };
  };

  meta.maintainers = with lib.maintainers; [
    nikstur
    willibutz
  ];
}
