{
  lib,
  makeSetupHook,
}:

makeSetupHook {
  name = "install-fonts-hook";

  meta = {
    description = "Copies standard font extension into their respective installation path";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      pancaek
      sigmanificient
      jopejoe1
    ];
  };
} ./install-fonts.sh
