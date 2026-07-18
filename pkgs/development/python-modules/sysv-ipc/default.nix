{
  lib,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "sysv-ipc";
  version = "1.2.0";

  src = fetchPypi {
    inherit version;
    sha256 = "sha256-75arM7ti5NFBQvC+BSTcwMPHDJZELfL8dzxnt8dRQZk=";
    pname = "sysv_ipc";
  };

  format = "setuptools";

  meta = {
    description = "SysV IPC primitives (semaphores, shared memory and message queues)";
    homepage = "http://semanchuk.com/philip/sysv_ipc/";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ ris ];
  };
}
