{
  buildDunePackage,
  melange,
  reason,
  reason-react-ppx,
}:

buildDunePackage (finalAttrs: {
  inherit (reason-react-ppx) version src;
  pname = "reason-react";

  nativeBuildInputs = [
    reason
    melange
  ];

  buildInputs = [
    reason-react-ppx
    melange
  ];

  doCheck = true;

  # Fix tests with dune 3.17.0
  # See https://github.com/reasonml/reason-react/issues/870
  preCheck = ''
    export DUNE_CACHE=disabled
  '';

  meta = reason-react-ppx.meta // {
    description = "Reason bindings for React.js";
  };
})
