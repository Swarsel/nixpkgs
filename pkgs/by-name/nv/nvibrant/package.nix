{
  lib,
  fetchFromGitHub,
  common-updater-scripts,
  coreutils,
  gitMinimal,
  python3Packages,
  writeShellScript,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "nvibrant";
  version = finalAttrs.passthru._version;
  # replaces code that depends on .git and uses of python -m {ninja,meson}
  patches = [ ./hatch_build.patch ];
  nativeBuildInputs = [ gitMinimal ];

  build-system = with python3Packages; [
    hatchling
    meson
    ninja
  ];

  configurePhase = ''
    export OLDEST_DRIVER_VERSION=${finalAttrs.passthru.oldestDriverVersion}
  '';

  dependencies = with python3Packages; [
    packaging
  ];

  postUnpack = ''
    mv open-gpu nvibrant/
    cd nvibrant
  '';

  pyproject = true;
  sourceRoot = ".";
  srcs = lib.attrValues finalAttrs.passthru.srcAttrs;

  passthru = {
    _version = lib.concatStringsSep "-" [
      finalAttrs.passthru.nvibrantVersion
      "unstable"
      finalAttrs.passthru.latestDriverVersion
    ];

    latestDriverVersion = "610.43.02";
    nvibrantVersion = "1.2.1";
    oldestDriverVersion = "515.43.04";

    srcAttrs = {
      nvibrant = fetchFromGitHub {
        hash = "sha256-M83WSQiJwzFZl8ECkZjKigvLTlMkzRa6o2hqPOt1378=";
        name = "nvibrant";
        owner = "tremeschin";
        repo = "nvibrant";
        tag = "v${finalAttrs.passthru.nvibrantVersion}";
      };

      open-gpu = fetchFromGitHub {
        # since .git isn't deterministic, we can't use it to checkout tags in
        # the build phase, so instead we generate patches for each version
        # upgrade before .git is removed and apply them incrementally
        fetchTags = true;
        hash = "sha256-MfLR5sYSjBrENWkCChcS9rk1zSlRFfTRpof/4lQ3qow=";
        name = "open-gpu";
        owner = "nvidia";

        postCheckout = ''
          cd $out

          while IFS= read -r tag; do
            echo "adding $tag"
            echo "$tag" >> SOURCE_TAGS

            if [[ "$tag" == ${finalAttrs.passthru.latestDriverVersion} ]]; then
              echo 'reached end of known tags'
              break
            fi
          done < <(git tag --sort v:refname)

          mkdir PATCHES

          prev_tag=${finalAttrs.passthru.oldestDriverVersion}
          while IFS= read -r tag; do
            if [ "$prev_tag" == "$tag" ]; then continue; fi

            echo "generating patch: $prev_tag -> $tag"
            git diff --minimal --binary "$prev_tag" "$tag" \
              > "PATCHES/$tag.patch"

            prev_tag=$tag
          done < SOURCE_TAGS
          unset prev_tag

          rm -rf .git
        '';

        repo = "open-gpu-kernel-modules";
        tag = finalAttrs.passthru.oldestDriverVersion;
      };
    };

    updateScript = writeShellScript "update-nvibrant" ''
      set -euo pipefail

      export PATH="${
        lib.makeBinPath [
          common-updater-scripts
          coreutils
          gitMinimal
        ]
      }:$PATH"

      list_tags() {
        git ls-remote --tags --sort v:refname --refs "$1" |
          cut --delimiter=/ --field=3-
      }

      readarray -t nvibrant_tags < <(list_tags \
        'https://github.com/tremeschin/nvibrant.git')

      readarray -t open_gpu_tags < <(list_tags \
        'https://github.com/nvidia/open-gpu-kernel-modules.git')

      update-source-version nvibrant "''${nvibrant_tags[-1]:1}" \
        --version-key=nvibrantVersion --source-key=srcAttrs.nvibrant \
        --ignore-same-hash --ignore-same-version

      update-source-version nvibrant "''${open_gpu_tags[0]}" \
        --version-key=oldestDriverVersion --source-key=srcAttrs.open-gpu \
        --ignore-same-hash --ignore-same-version

      update-source-version nvibrant "''${open_gpu_tags[-1]}" \
        --version-key=latestDriverVersion --source-key=srcAttrs.open-gpu \
        --ignore-same-hash --ignore-same-version
    '';
  };

  meta = {
    description = "Configure NVIDIA's Digital Vibrance on Wayland";
    homepage = "https://github.com/Tremeschin/nvibrant";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      mikaeladev
    ];

    platforms = lib.platforms.linux;
    mainProgram = "nvibrant";
  };
})
