wget ftp://rostlab.org/free/freecontact-1.0.21.tar.xz
tar xf freecontact-1.0.21.tar.xz

yum install atlas-devel
# and assuming that boost, fortran and other "standard" libs are already installed

cd freecontact-1.0.21
LDFLAGS=-L/usr/lib64/atlas ./configure --with-blas=tatlas
patch lib/freecontact.cpp ../freecontact.patch
make
sudo make install

# To make it run on other nodes, use ldd to check what libs are required by freecontact, and copy them manually to ~/lib64. Copy the binary to ~/bin.
