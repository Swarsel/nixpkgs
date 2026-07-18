# Python 2 overlay applied to resholve's local python27 package set.
# Provides the bootstrap toolchain (bootstrapped-pip/pip/setuptools/wheel)
# plus resholve's own python2 build dependencies, kept here so all of
# resholve's python2 surface lives in one place.

self: super:

with self;
with super;
{
  bootstrapped-pip = toPythonModule (callPackage ./python2-modules/bootstrapped-pip { });
  # resholve build deps
  configargparse = callPackage ./python2-modules/configargparse { };
  oildev = callPackage ./python2-modules/oildev { };
  pip = callPackage ./python2-modules/pip { };
  sedparse = callPackage ./python2-modules/sedparse { };
  setuptools = callPackage ./python2-modules/setuptools { };
  six = callPackage ./python2-modules/six { };
  typing = callPackage ./python2-modules/typing { };
  wheel = callPackage ./python2-modules/wheel { };
}
