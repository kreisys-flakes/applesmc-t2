{ stdenv, kernel, kmod
, pname
, description
, src }:

stdenv.mkDerivation rec {
  inherit pname src;
  version = "git-${kernel.version}";

  sourceRoot = "source/applesmc";
  hardeningDisable = [ "pic" "format" ];
  nativeBuildInputs = kernel.moduleBuildDependencies;
  buildInputs = [ kmod ];

  makefile = ./Makefile;

  makeFlags = [
    "KERNELRELEASE=${kernel.modDirVersion}"
    "KERNEL_DIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "INSTALL_MOD_PATH=$(out)"
  ];

  meta = with stdenv.lib; {
    inherit description;
    homepage = "https://github.com/MCMrARM/mbp2018-etc";
    license = licenses.gpl2;
    platforms = platforms.linux;
  };
}
