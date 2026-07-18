{ lib }:

{
  meta = {
    description = "GNU sed, a batch stream editor";
    homepage = "https://www.gnu.org/software/sed";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.unix;
    mainProgram = "sed";
    teams = [ lib.teams.minimal-bootstrap ];
  };
}
