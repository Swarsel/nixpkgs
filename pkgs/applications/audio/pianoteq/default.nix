{
  lib,
  stdenv,
  alsa-lib,
  autoPatchelfHook,
  copyDesktopItems,
  curl,
  freetype,
  htmlq,
  jq,
  libglvnd,
  librsvg,
  makeDesktopItem,
  makeWrapper,
  p7zip,
  writeShellScript,
}:
let
  versionForFile = v: builtins.replaceStrings [ "." ] [ "" ] v;

  archdirs =
    if stdenv.hostPlatform.isx86_64 then
      [
        "x86-64bit"
        "amd64"
      ]
    else if stdenv.hostPlatform.isAarch64 then
      [
        "arm-64bit"
        "arm"
      ]
    else
      throw "unsupported platform";

  mkPianoteq =
    {
      mainProgram,
      name,
      src,
      startupWMClass,
      version,
      ...
    }:
    stdenv.mkDerivation (finalAttrs: {
      inherit src version;
      pname = "pianoteq-${name}";

      nativeBuildInputs = [
        autoPatchelfHook
        copyDesktopItems
        makeWrapper
        librsvg
      ];

      buildInputs = [
        (lib.getLib stdenv.cc.cc) # libgcc_s.so.1, libstdc++.so.6
        alsa-lib # libasound.so.2
        freetype # libfreetype.so.6
        libglvnd # libGL.so.1
      ];

      installPhase = ''
        runHook preInstall
        mkdir -p $out/bin
        mv -t $out/bin ${builtins.concatStringsSep " " (map (dir: "Pianoteq*/${dir}/*") archdirs)}
        install -Dm644 ${./pianoteq.svg} $out/share/icons/hicolor/scalable/apps/pianoteq.svg
        for size in 16 22 32 48 64 128 256; do
          dir=$out/share/icons/hicolor/"$size"x"$size"/apps
          mkdir -p $dir
          rsvg-convert \
            --keep-aspect-ratio \
            --width $size \
            --height $size \
            --output $dir/pianoteq.png \
            ${./pianoteq.svg}
        done
        runHook postInstall
      '';

      desktopItems = [
        (makeDesktopItem {
          inherit startupWMClass;

          categories = [
            "AudioVideo"
            "Audio"
            "Recorder"
          ];

          comment = finalAttrs.meta.description;
          desktopName = mainProgram;
          exec = ''"${mainProgram}"'';
          icon = "pianoteq";
          name = finalAttrs.pname;
          startupNotify = false;
        })
      ];

      unpackPhase = ''
        ${p7zip}/bin/7z x $src
      '';

      meta = {
        inherit mainProgram;
        description = "Software synthesizer that features real-time MIDI-control of digital physically modeled pianos and related instruments";
        homepage = "https://www.modartt.com/pianoteq";
        license = lib.licenses.unfree;
        sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];

        maintainers = with lib.maintainers; [
          mausch
          ners
        ];

        platforms = [
          "x86_64-linux"
          "aarch64-linux"
        ];
      };
    });

  fetchWithCurlScript =
    {
      hash,
      name,
      script,
      impureEnvVars ? [ ],
    }:
    stdenv.mkDerivation {
      inherit name;
      nativeBuildInputs = [ curl ];

      builder = writeShellScript "builder.sh" ''
        curlVersion=$(${curl}/bin/curl -V | head -1 | cut -d' ' -f2)

        # Curl flags to handle redirects, not use EPSV, handle cookies for
        # servers to need them during redirects, and work on SSL without a
        # certificate (this isn't a security problem because we check the
        # cryptographic hash of the output anyway).
        curl=(
            ${curl}/bin/curl
            --location
            --max-redirs 20
            --retry 3
            --disable-epsv
            --cookie-jar cookies
            --insecure
            --user-agent "curl/$curlVersion Nixpkgs/${lib.trivial.release}"
            $NIX_CURL_FLAGS
        )

        ${script}

      '';

      impureEnvVars =
        lib.fetchers.proxyImpureEnvVars
        ++ impureEnvVars
        ++ [
          # This variable allows the user to pass additional options to curl
          "NIX_CURL_FLAGS"
        ];

      outputHash = hash;
      outputHashAlgo = "sha256";
    };

  fetchPianoteqTrial =
    { hash, name }:
    fetchWithCurlScript {
      inherit name hash;

      script = ''
        html=$(
          "''${curl[@]}" --silent --request GET \
            --cookie cookies \
            --header "accept: */*" \
            'https://www.modartt.com/try?file=${name}'
        )

        signature="$(echo "$html" | ${htmlq}/bin/htmlq '#download-form' --attribute action | cut -f2 -d'&' | cut -f2 -d=)"

        json=$(
          "''${curl[@]}" --silent --request POST \
          --cookie cookies \
          --header "modartt-json: request" \
          --header "origin: https://www.modartt.com" \
          --header "content-type: application/json; charset=UTF-8" \
          --header "accept: application/json, text/javascript, */*" \
          --data-raw '{"file": "${name}", "get": "url", "signature": "'"$signature"'"}' \
          https://www.modartt.com/api/0/download
        )

        url=$(echo $json | ${jq}/bin/jq -r .url)
        if [ "$url" == "null"  ]; then
          echo "Could not get download URL, open an issue on https://github.com/NixOS/nixpkgs"
          return 1
        fi
        "''${curl[@]}" --progress-bar --cookie cookies -o $out "$url"
      '';
    };

  fetchPianoteqWithLogin =
    { hash, name }:
    fetchWithCurlScript {
      inherit name hash;

      impureEnvVars = [
        "NIX_MODARTT_USERNAME"
        "NIX_MODARTT_PASSWORD"
      ];

      script = ''
        if [ -z "''${NIX_MODARTT_USERNAME}" -o -z "''${NIX_MODARTT_PASSWORD}" ]; then
          echo "Error: Downloading a personal Pianoteq instance requires the nix building process (nix-daemon in multi user mode) to have the NIX_MODARTT_USERNAME and NIX_MODARTT_PASSWORD env vars set." >&2
          exit 1
        fi

        "''${curl[@]}" -s -o /dev/null "https://www.modartt.com/user_area"

        ${jq}/bin/jq -n "{connect: 1, login: \"''${NIX_MODARTT_USERNAME}\", password: \"''${NIX_MODARTT_PASSWORD}\"}" > login.json

        "''${curl[@]}" --silent --request POST \
          --cookie cookies \
          --referer "https://www.modartt.com/user_area" \
          --header "modartt-json: request" \
          --header "origin: https://www.modartt.com" \
          --header "content-type: application/json; charset=UTF-8" \
          --header "accept: application/json, text/javascript, */*" \
          --data @login.json \
          https://www.modartt.com/api/0/session

        json=$(
          "''${curl[@]}" --silent --request POST \
          --cookie cookies \
          --header "modartt-json: request" \
          --header "origin: https://www.modartt.com" \
          --header "content-type: application/json; charset=UTF-8" \
          --header "accept: application/json, text/javascript, */*" \
          --data-raw '{"file": "${name}", "get": "url"}' \
          https://www.modartt.com/api/0/download
        )

        url=$(echo $json | ${jq}/bin/jq -r .url)
        "''${curl[@]}" --progress-bar --cookie cookies -o $out "$url"
      '';
    };

  version6 = "6.7.3";
  version7 = "7.5.4";
  version8 = "8.4.0";

  mkStandard =
    version: hash:
    mkPianoteq {
      inherit version;

      src = fetchPianoteqWithLogin {
        inherit hash;
        name = "pianoteq_linux_v${versionForFile version}.7z";
      };

      mainProgram = "Pianoteq ${lib.versions.major version}";
      name = "standard";
      startupWMClass = "Pianoteq";
    };
  mkStage =
    version: hash:
    mkPianoteq {
      inherit version;

      src = fetchPianoteqWithLogin {
        inherit hash;
        name = "pianoteq_stage_linux_v${versionForFile version}.7z";
      };

      mainProgram = "Pianoteq ${lib.versions.major version} STAGE";
      name = "stage";
      startupWMClass = "Pianoteq STAGE";
    };
  mkStandardTrial =
    version: hash:
    mkPianoteq {
      inherit version;

      src = fetchPianoteqTrial {
        inherit hash;
        name = "pianoteq_linux_trial_v${versionForFile version}.7z";
      };

      mainProgram = "Pianoteq ${lib.versions.major version}";
      name = "standard-trial";
      startupWMClass = "Pianoteq Trial";
    };
  mkStageTrial =
    version: hash:
    mkPianoteq {
      inherit version;

      src = fetchPianoteqTrial {
        inherit hash;
        name = "pianoteq_stage_linux_trial_v${versionForFile version}.7z";
      };

      mainProgram = "Pianoteq ${lib.versions.major version} STAGE";
      name = "stage-trial";
      startupWMClass = "Pianoteq STAGE Trial";
    };
in
{
  stage-trial_6 = mkStageTrial version6 "sha256-zrv0c/Mxt1EysR7ZvmxtksXAF5MyXTFMNj4KAdO3QnE=";
  stage-trial_7 = mkStageTrial version7 "sha256-ybtq+hjnaQxpLxv2KE0ZcbQXtn5DJJsnMwCmh3rlrIc=";
  stage-trial_8 = mkStageTrial version8 "sha256-k0p7SnkEq90bqIlT7PTYAQuhKEDVi+srHwYrpMUtIbM=";
  stage_6 = mkStage version6 "";
  stage_7 = mkStage version7 "";
  stage_8 = mkStage version8 "";
  standard-trial_6 = mkStandardTrial version6 "sha256-nHTAqosOJqC0VnRw2/xVpZ6y02vvau6CgfNmgiN/AHs=";
  standard-trial_7 = mkStandardTrial version7 "sha256-3a3+SKTEhvDtqK5Kg4E6KiLvn5+j6JN6ntIb72u2bdQ=";
  standard-trial_8 = mkStandardTrial version8 "sha256-K3LbAWxciXt9hVAyRayxSoE/IYJ38Fd03+j0s7ZsMuw=";
  standard_6 = mkStandard version6 "sha256-u6ZNpmHFVOk+r+6Q8OURSfAi41cxMoDvaEXrTtHEAVY=";
  standard_7 = mkStandard version7 "sha256-TA9CiuT21fQedlMUGz7bNNxYun5ArmRjvIxjOGqXDCs=";
  standard_8 = mkStandard version8 "sha256-ZDGB/SOOz+sWz7P+sNzyaipEH452n8zq5LleO3ztSXc=";
}
