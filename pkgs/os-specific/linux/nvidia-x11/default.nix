{
  lib,
  stdenv,
  fetchFromGitHub,
  callPackage,
  fetchgit,
  fetchpatch,
  kernel,
  pkgsi686Linux,
}:

let
  generic =
    args:
    let
      imported = import ./generic.nix args;
    in
    callPackage imported {
      lib32 =
        (pkgsi686Linux.callPackage imported {
          libsOnly = true;
        }).out;
    };

  selectHighestVersion = a: b: if lib.versionOlder a.version b.version then b else a;

  # https://forums.developer.nvidia.com/t/linux-6-7-3-545-29-06-550-40-07-error-modpost-gpl-incompatible-module-nvidia-ko-uses-gpl-only-symbol-rcu-read-lock/280908/19
  rcu_patch = fetchpatch {
    hash = "sha256-eZiQQp2S/asE7MfGvfe6dA/kdCvek9SYa/FFGp24dVg=";
    url = "https://github.com/gentoo/gentoo/raw/c64caf53/x11-drivers/nvidia-drivers/files/nvidia-drivers-470.223.02-gpl-pfn_valid.patch";
  };

  # Fixes drm device not working with linux 6.12
  # https://github.com/NVIDIA/open-gpu-kernel-modules/issues/712
  drm_fop_flags_linux_612_patch = fetchpatch {
    hash = "sha256-+SfIu3uYNQCf/KXhv4PWvruTVKQSh4bgU1moePhe57U=";
    url = "https://github.com/Binary-Eater/open-gpu-kernel-modules/commit/8ac26d3c66ea88b0f80504bdd1e907658b41609d.patch";
  };

  # Source corresponding to https://aur.archlinux.org/packages/nvidia-390xx-dkms
  aurPatches = fetchgit {
    hash = "sha256-SERB5ihOroagJn7apAiqjUckbrfP2FZPCuTLWcBccoM=";
    rev = "cf1a1c571c425b4b66d12e468fc4ce45a397c583";
    url = "https://aur.archlinux.org/nvidia-390xx-utils.git";
  };

  # https://github.com/NVIDIA/open-gpu-kernel-modules/issues/840
  gpl_symbols_linux_615_patch = fetchpatch {
    extraPrefix = "kernel/";
    hash = "sha256-YOTAvONchPPSVDP9eJ9236pAPtxYK5nAePNtm2dlvb4=";
    stripLen = 1;
    url = "https://github.com/CachyOS/kernel-patches/raw/914aea4298e3744beddad09f3d2773d71839b182/6.15/misc/nvidia/0003-Workaround-nv_vm_flags_-calling-GPL-only-code.patch";
  };

  kernel_6_19_patch = fetchpatch {
    hash = "sha256-YuJjSUXE6jYSuZySYGnWSNG5sfVei7vvxDcHx3K+IN4=";
    url = "https://github.com/CachyOS/CachyOS-PKGBUILDS/raw/d5629d64ac1f9e298c503e407225b528760ffd37/nvidia/nvidia-utils/kernel-6.19.patch";
  };
in
rec {
  beta = generic {
    version = "595.45.04";
    openSha256 = "sha256-uqNfImwTKhK8gncUdP1TPp0D6Gog4MSeIJMZQiJWDoE=";
    persistencedSha256 = "sha256-5FoeUaRRMBIPEWGy4Uo0Aho39KXmjzQsuAD9m/XkNpA=";
    settingsSha256 = "sha256-Y45pryyM+6ZTJyRaRF3LMKaiIWxB5gF5gGEEcQVr9nA=";
    sha256_64bit = "sha256-zUllSSRsuio7dSkcbBTuxF+dN12d6jEPE0WgGvVOj14=";
    sha256_aarch64 = "sha256-jl6lQWsgF6ya22sAhYPpERJ9r+wjnWzbGnINDpUMzsk=";
  };

  bleeding_edge = selectHighestVersion latest beta;
  # data center driver compatible with current default cudaPackages
  dc = dc_580;

  dc_570 = generic rec {
    version = "570.172.08";
    fabricmanagerSha256 = "sha256-jSTKzeRVTUcYma1Cb0ajSdXKCi6KzUXCp2OByPSWSR4=";
    openSha256 = "sha256-aTV5J4zmEgRCOavo6wLwh5efOZUG+YtoeIT/tnrC1Hg=";
    persistencedSha256 = "sha256-x4K0Gp89LdL5YJhAI0AydMRxl6fyBylEnj+nokoBrK8=";
    sha256_64bit = "sha256-AlaGfggsr5PXsl+nyOabMWBiqcbHLG4ij617I4xvoX0=";
    url = "https://us.download.nvidia.com/tesla/${version}/NVIDIA-Linux-x86_64-${version}.run";
    useFabricmanager = true;
    usePersistenced = true;
    useSettings = false;
  };

  dc_580 = generic rec {
    version = "580.159.04";
    fabricmanagerSha256 = "sha256-Jk6XVn/d6vqfxYGAACiD9UHelnjdC4+zOi4EEv8LuKE=";
    openSha256 = "sha256-zsNmjZW0cyZWPp3vDT3mNeqAo0hS0M7e9Tbvwvij+F4=";
    persistencedSha256 = "sha256-vDawiy52GB8JABUKZDiQUc8uda8p/7jCFW7rTu6QMa4=";
    sha256_64bit = "sha256-weZnYbCI0Xs632y2l53przi+JoTRArABoXbc+vq9yh4=";
    url = "https://us.download.nvidia.com/tesla/${version}/NVIDIA-Linux-x86_64-${version}.run";
    useFabricmanager = true;
    usePersistenced = true;
    useSettings = false;
  };

  dc_590 = generic rec {
    version = "590.48.01";
    fabricmanagerSha256 = "sha256-f/AQ8HrgoqBQyXNrXA/UaI4OMQ9QcjjYWIhr1/5uM74=";
    openSha256 = "sha256-hECHfguzwduEfPo5pCDjWE/MjtRDhINVr4b1awFdP44=";
    persistencedSha256 = "sha256-wsNeuw7IaY6Qc/i/AzT/4N82lPjkwfrhxidKWUtcwW8=";
    sha256_64bit = "sha256-ueL4BpN4FDHMh/TNKRCeEz3Oy1ClDWto1LO/LWlr1ok=";
    url = "https://us.download.nvidia.com/tesla/${version}/NVIDIA-Linux-x86_64-${version}.run";
    useFabricmanager = true;
    usePersistenced = true;
    useSettings = false;
  };

  latest = selectHighestVersion production new_feature;

  legacy_340 =
    let
      # Source corresponding to https://aur.archlinux.org/packages/nvidia-340xx-dkms
      aurPatches = fetchFromGitHub {
        hash = "sha256-1qlYc17aEbLD4W8XXn1qKryBk2ltT6cVIv5zAs0jXZo=";
        owner = "archlinux-jerry";
        repo = "nvidia-340xx";
        rev = "7616dfed253aa93ca7d2e05caf6f7f332c439c90";
      };
      patchset = [
        "0001-kernel-5.7.patch"
        "0002-kernel-5.8.patch"
        "0003-kernel-5.9.patch"
        "0004-kernel-5.10.patch"
        "0005-kernel-5.11.patch"
        "0006-kernel-5.14.patch"
        "0007-kernel-5.15.patch"
        "0008-kernel-5.16.patch"
        "0009-kernel-5.17.patch"
        "0010-kernel-5.18.patch"
        "0011-kernel-6.0.patch"
        "0012-kernel-6.2.patch"
        "0013-kernel-6.3.patch"
        "0014-kernel-6.5.patch"
        "0015-kernel-6.6.patch"
      ];
    in
    generic {
      version = "340.108";
      patches = map (patch: "${aurPatches}/${patch}") patchset;

      # fixes the bug described in https://bbs.archlinux.org/viewtopic.php?pid=2083439#p2083439
      # see https://bbs.archlinux.org/viewtopic.php?pid=2083651#p2083651
      # and https://bbs.archlinux.org/viewtopic.php?pid=2083699#p2083699
      postInstall = ''
        mv $out/lib/tls/* $out/lib
        rmdir $out/lib/tls
      '';

      broken = kernel.kernelAtLeast "6.7";
      persistencedSha256 = "1ax4xn3nmxg1y6immq933cqzw6cj04x93saiasdc0kjlv0pvvnkn";
      settingsSha256 = "0zm29jcf0mp1nykcravnzb5isypm8l8mg2gpsvwxipb7nk1ivy34";
      sha256_32bit = "1jkwa1phf0x4sgw8pvr9d6krmmr3wkgwyygrxhdazwyr2bbalci0";
      sha256_64bit = "06xp6c0sa7v1b82gf0pq0i5p0vdhmm3v964v0ypw36y0nzqx8wf6";
      useGLVND = false;
    };

  # Last one supporting x86
  legacy_390 = generic {
    version = "390.157";

    patches = map (patch: "${aurPatches}/${patch}") [
      "kernel-4.16+-memory-encryption.patch"
      "kernel-6.2.patch"
      "kernel-6.3.patch"
      "kernel-6.4.patch"
      "kernel-6.5.patch"
      "kernel-6.6.patch"
      "kernel-6.8.patch"
      "gcc-14.patch"
      "kernel-6.10.patch"
      "kernel-6.12.patch"
      "kernel-6.13.patch"
      "kernel-6.14.patch"
      "gcc-15.patch"
      "kernel-6.15.patch"
      "kernel-6.17.patch"
    ];

    # fixes the bug described in https://bbs.archlinux.org/viewtopic.php?pid=2083439#p2083439
    # see https://bbs.archlinux.org/viewtopic.php?pid=2083651#p2083651
    # and https://bbs.archlinux.org/viewtopic.php?pid=2083699#p2083699
    postInstall = ''
      mv $out/lib/tls/* $out/lib
      rmdir $out/lib/tls
    '';

    broken = kernel.kernelAtLeast "6.18";
    persistencedSha256 = "sha256-NuqUQbVt80gYTXgIcu0crAORfsj9BCRooyH3Gp1y1ns=";
    settingsSha256 = "sha256-uJZO4ak/w/yeTQ9QdXJSiaURDLkevlI81de0q4PpFpw=";
    sha256_32bit = "sha256-VdZeCkU5qct5YgDF8Qgv4mP7CVHeqvlqnP/rioD3B5k=";
    sha256_64bit = "sha256-W+u8puj+1da52BBw+541HxjtxTSVJVPL3HHo/QubMoo=";
  };

  # Last one supporting Kepler architecture
  legacy_470 =
    let
      # Source corresponding to https://aur.archlinux.org/packages/nvidia-470xx-dkms
      aurPatches = fetchgit {
        hash = "sha256-hRBws0o4DWI5fvZRn0OwitXRSR9HCkRkgnvnkiZI6Ko=";
        rev = "7abbeeb510742be09e1eb806c14bab2833a25783";
        url = "https://aur.archlinux.org/nvidia-470xx-utils.git";
      };
    in
    generic {
      version = "470.256.02";

      patches = map (patch: "${aurPatches}/${patch}") [
        "0001-Fix-conftest-to-ignore-implicit-function-declaration.patch"
        "0002-Fix-conftest-to-use-a-short-wchar_t.patch"
        "0003-Fix-conftest-to-use-nv_drm_gem_vmap-which-has-the-se.patch"
        "nvidia-470xx-fix-gcc-15.patch"
        "kernel-6.10.patch"
        "kernel-6.12.patch"
        "nvidia-470xx-fix-linux-6.13.patch"
        "nvidia-470xx-fix-linux-6.14.patch"
        "nvidia-470xx-fix-linux-6.15.patch"
        "nvidia-470xx-fix-linux-6.17.patch"
        "nvidia-470xx-fix-linux-6.19-part1.patch"
        "nvidia-470xx-fix-linux-6.19-part2.patch"
        "nvidia-470xx-fix-linux-7.0.patch"
      ];

      patchFlags = [
        "-p1"
        "--directory=kernel"
      ];

      persistencedSha256 = "sha256-iYoSib9VEdwjOPBP1+Hx5wCIMhW8q8cCHu9PULWfnyQ=";
      settingsSha256 = "sha256-kftQ4JB0iSlE8r/Ze/+UMnwLzn0nfQtqYXBj+t6Aguk=";
      sha256_64bit = "sha256-1kUYYt62lbsER/O3zWJo9z6BFowQ4sEFl/8/oBNJsd4=";
      sha256_aarch64 = "sha256-e+QvE+S3Fv3JRqC9ZyxTSiCu8gJdZXSz10gF/EN6DY0=";
    };

  # Last one without the bug reported here:
  # https://bbs.archlinux.org/viewtopic.php?pid=2155426#p2155426
  legacy_535 = generic {
    version = "535.288.01";
    openSha256 = "sha256-kDM8jeHjcRCyhOs8AQk+ce3Qzf2cI5RGzzIraJrSmOE=";
    persistencedSha256 = "sha256-q061VN6om3UzbpWD7+tJJVgU/e2YCJF4IgEv53qx9ZA=";
    settingsSha256 = "sha256-hN4IWAD/M+th7brbzdBtgOQ2P1QUVrrWITgVGiuCxWw=";
    sha256_64bit = "sha256-8gwy/W7NH3BcbfJ5fAwIQlPs9/9I8sNH+Co5YZiC7OE=";
    sha256_aarch64 = "sha256-2d3RYzU+W4uS6mUvpCNCfoVcAJA/aerNwm7Xbg0YJBo=";
  };

  # Update note:
  # If you add a legacy driver here, also update `top-level/linux-kernels.nix`,
  # adding to the `nvidia_x11_legacy*` entries.
  # LTSB supported until Aug 2028
  legacy_580 = generic {
    version = "580.173.02";
    openSha256 = "sha256-lhloZdf6XbaAFTZBF1DxE0Nv9VC6obY8UPf0VyfVepE=";
    persistencedSha256 = "sha256-j8YM1w231X+JIP3c3TpUNurEBumEu1stVjzFGWu1JXE=";
    settingsSha256 = "sha256-dfdu/3tnwHUfP7WoeQFNOMalMlpmUWjeMDIOnu+yi8E=";
    sha256_64bit = "sha256-jY65AB4FqaimY9PV0wT+tk7yhE7hhczf2VJ4aCD0bhs=";
    sha256_aarch64 = "sha256-1lvVYIfvTXjwSoCNp4g8NaWQHF/TfpXRUKdgLrqXqoA=";
  };

  mkDriver = generic;

  new_feature = generic {
    version = "610.43.03";
    openSha256 = "sha256-QCXmqo2xNyIwjGv0da2MUC8ex641Mmc5DUI+uRFVwgE=";
    persistencedSha256 = "sha256-sOKUsAFHh0/COH+nNgbH9+7hWgivOzq4YmTuk9MOFfI=";
    settingsSha256 = "sha256-z/t+SdEQdVJPwjKIRHO02d264Kt47eWiOwwsaxmh4xQ=";
    sha256_64bit = "sha256-ReLUwTSiPDXlDyU6SqY+fl6NF+PRhdSgfIpY6WEu05I=";
    sha256_aarch64 = "sha256-jSdlXo60ilXLKWKvZfgbBnVqVYuw6zhnGuiDgwxYz94=";
  };

  production = generic {
    version = "595.84";
    openSha256 = "sha256-pEmA2tUcOKwUPKy6N0QvS49Pdut4/7Phs/JhjdyBcNY=";
    persistencedSha256 = "sha256-50xYdgx7EEThbaMp4QS8GADbxj0mhBXh8QQN0tWMwRg=";
    settingsSha256 = "sha256-QrnBM+sdWO4GanO62rxpHmRrjYkYpl5RD6fIiHq4C4A=";
    sha256_64bit = "sha256-mcQE5SExvye8ptoCaNzOPr7cenOrF0BxqZXPGmxeugY=";
    sha256_aarch64 = "sha256-GloNdDFfmXFVu4FAlNNk2qzqLOuw2N5CKatKkcSrQxk=";
  };

  # Official Unix Drivers - https://www.nvidia.com/en-us/drivers/unix/
  # Branch/Maturity data - http://people.freedesktop.org/~aplattner/nvidia-versions.txt
  # Policy: use the highest stable version as the default (on our master).
  stable = if stdenv.hostPlatform.system == "i686-linux" then legacy_390 else production;

  # Vulkan developer beta driver
  # See here for more information: https://developer.nvidia.com/vulkan-driver
  vulkan_beta = generic rec {
    version = "595.44.09";
    openSha256 = "sha256-QboSiRWRZWseFg7GN/a4vZVQGGBF1UJlC9MyAxUxyF4=";
    persistencedSha256 = "sha256-5FoeUaRRMBIPEWGy4Uo0Aho39KXmjzQsuAD9m/XkNpA=";
    persistencedVersion = "595.45.04";
    settingsSha256 = "sha256-Y45pryyM+6ZTJyRaRF3LMKaiIWxB5gF5gGEEcQVr9nA=";
    settingsVersion = "595.45.04";
    sha256_64bit = "sha256-LOcwE47hUG1aZX7JvLmTb/yC5qQgXYZ0TAavSn38Xug=";
    url = "https://developer.nvidia.com/downloads/vulkan-beta-${lib.concatStrings (lib.splitVersion version)}-linux";
  };
}
