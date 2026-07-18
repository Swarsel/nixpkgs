{
  lib,
  fetchurl,
  alcotest,
  buildDunePackage,
  ctypes,
  file,
  result,
}:

let
  generic =
    {
      sha256,
      version,
    }:
    buildDunePackage (finalAttrs: {
      inherit version;
      pname = "luv";

      src = fetchurl {
        inherit sha256;
        url = "https://github.com/aantron/luv/releases/download/${finalAttrs.version}/luv-${finalAttrs.version}.tar.gz";
      };

      patches = lib.optional (lib.versionOlder version "0.5.14") ./incompatible-pointer-type-fix.diff;
      nativeBuildInputs = [ file ];

      propagatedBuildInputs = [
        ctypes
        result
      ];

      postConfigure = ''
        substituteInPlace "src/c/vendor/configure/ltmain.sh" --replace-fail /usr/bin/file file
      '';

      doCheck = true;
      checkInputs = [ alcotest ];

      meta = {
        description = "Binding to libuv: cross-platform asynchronous I/O";
        homepage = "https://github.com/aantron/luv";

        # MIT-licensed, extra licenses apply partially to libuv vendor
        license = with lib.licenses; [
          mit
          bsd2
          bsd3
          cc-by-sa-40
        ];

        maintainers = with lib.maintainers; [
          locallycompact
          sternenseemann
        ];
      };
    });
in
{
  luv = generic {
    version = "0.5.14";
    sha256 = "sha256-jgG0pQyIds3ZjY4kXAaHxNxNiDrtFhrZxazh+x/arpk=";
  };

  luv-0-5-12 = generic {
    version = "0.5.12";
    sha256 = "sha256-dp9qCIYqSdROIAQ+Jw73F3vMe7hnkDe8BgZWImNMVsA=";
  };
}
