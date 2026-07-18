{
  lib,
  QuickChick,
  coq,
  itree-io,
  json,
  mkCoqDerivation,
  version ? null,
}:

mkCoqDerivation {
  inherit version;
  pname = "async-test";

  propagatedBuildInputs = [
    itree-io
    json
    QuickChick
  ];

  defaultVersion =
    let
      inherit (lib.versions) range;
    in
    lib.switch coq.coq-version [
      {
        case = range "8.12" "8.19";
        out = "0.1.0";
      }
    ] null;

  owner = "liyishuai";

  release = {
    "0.1.0".hash = "sha256-0DBUS20337tpBi64mlJIWTQvIAdUvWbFCM9Sat7MEA8=";
  };

  releaseRev = v: "v${v}";
  repo = "coq-async-test";

  meta = {
    description = "From interaction trees to asynchronous tests";
    license = lib.licenses.mpl20;
  };
}
