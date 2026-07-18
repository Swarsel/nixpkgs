{
  lib,
  stdenv,
  fetchurl,
  fetchDebianPatch,
  unzip,
}:

stdenv.mkDerivation rec {
  pname = "chntpw";
  version = "140201";

  src = fetchurl {
    url = "https://pogostick.net/~pnh/ntpasswd/chntpw-source-${version}.zip";
    sha256 = "1k1cxsj0221dpsqi5yibq2hr7n8xywnicl8yyaicn91y8h2hkqln";
  };

  patches =
    let
      fetchChntpwDebianPatch =
        { hash, patch }:
        fetchDebianPatch {
          inherit
            hash
            patch
            pname
            version
            ;

          debianRevision = "1.2";
        };
    in
    [
      ./00-chntpw-build-arch-autodetect.patch
      ./01-chntpw-install-target.patch
      # Import various bug fixes from debian
      (fetchChntpwDebianPatch {
        hash = "sha256-FuEEp/nZ3xNIpemcRTXPThxvQ7ZeB0REOqs0/Jl6AJ4=";
        patch = "04_get_abs_path";
      })
      (fetchChntpwDebianPatch {
        hash = "sha256-DQ55aRPM1uZOA6Q+C3ISJV0JayWFh2MRSnGuGtdAjwI=";
        patch = "06_correct_test_open_syscall";
      })
      (fetchChntpwDebianPatch {
        hash = "sha256-lPDOY4ZKSZgLvfdPyurgGjvzzUCDU2JJ9/gKmK/tZl4=";
        patch = "07_detect_failure_to_write_key";
      })
      (fetchChntpwDebianPatch {
        hash = "sha256-+gOoZuPwGp4byaNJ2dpb8kj6pohXDU1M1YIBqWR197w=";
        patch = "08_no_deref_null";
      })
      (fetchChntpwDebianPatch {
        hash = "sha256-SsX94ds80ccDe8pFAEbg8D4r4XK1cXZsVLbHAHybX9s=";
        patch = "09_improve_robustness";
      })
      (fetchChntpwDebianPatch {
        hash = "sha256-7+FXU7cMEAwtkoWnBRZnsN0Y75T66pyTwexgcSQ0FHs=";
        patch = "11_improve_documentation";
      })
      (fetchChntpwDebianPatch {
        hash = "sha256-RDly35sTVxuzEqH7ZXvh8fFC76B2oSfrw87QK9zxrM8=";
        patch = "12_readonly_filesystem";
      })
      (fetchChntpwDebianPatch {
        hash = "sha256-e2bM7TKyItJPaj3wyObuGQNve/QLCTvyqjNP2T2jaJg=";
        patch = "13_write_to_hive";
      })
      (fetchChntpwDebianPatch {
        hash = "sha256-OhexHr6rGTqM/XFJ0vS3prtI+RdcgjUtEfsT2AibxYc=";
        patch = "14_improve_description";
      })
      (fetchChntpwDebianPatch {
        hash = "sha256-ir9LFl8FJq141OwF5SbyVMtjQ1kTMH1NXlHl0XZq7m8=";
        patch = "17_hexdump-pointer-type.patch";
      })
    ];

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    make install PREFIX=$out
  '';

  meta = {
    description = "Utility to reset the password of any user that has a valid local account on a Windows system";
    homepage = "http://pogostick.net/~pnh/ntpasswd/";
    license = lib.licenses.gpl2Only;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
}
