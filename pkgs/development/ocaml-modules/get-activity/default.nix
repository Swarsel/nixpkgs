{
  lib,
  alcotest,
  buildDunePackage,
  cmdliner,
  dune-build-info,
  fetchpatch,
  fmt,
  get-activity-lib,
  logs,
  ppx_expect,
}:

buildDunePackage (finalAttrs: {
  inherit (get-activity-lib) version src;
  pname = "get-activity";

  patches = [
    # Compatibility with cmdliner ≥ 2.0
    (fetchpatch {
      hash = "sha256-6uvkBEI/ZCPrJ3Aus0/L86zUIa+kOBD0k8ADMEi+pkI=";
      url = "https://github.com/tarides/get-activity/commit/3f1ccbbcf7fc65c69c7752726f6886fc92b986fa.patch";
    })
  ];

  buildInputs = [
    get-activity-lib
    cmdliner
    dune-build-info
    fmt
    logs
  ];

  doCheck = true;

  checkInputs = [
    ppx_expect
    alcotest
  ];

  meta = {
    description = "Collect activity and format as markdown for a journal";
    homepage = "https://github.com/tarides/get-activity";
    changelog = "https://github.com/tarides/get-activity/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ zazedd ];
  };
})
