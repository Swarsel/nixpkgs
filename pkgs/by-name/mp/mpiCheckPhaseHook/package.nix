{
  lib,
  stdenv,
  makeSetupHook,
  openmpCheckPhaseHook,
}:

makeSetupHook {
  name = "mpi-checkPhase-hook";

  propagatedNativeBuildInputs = [
    openmpCheckPhaseHook
  ];

  substitutions = {
    iface = if stdenv.hostPlatform.isDarwin then "lo0" else "lo";
    topology = ./topology.xml;
  };

  meta.license = lib.licenses.mit;
} ./mpi-check-hook.sh
