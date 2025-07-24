# Apptainer-tools

Apptainer is an alternative to docker or podman. It's essentially container tech for HPC. 

# Before using

Make sure your user session won't be killed by systemd, using either a dummy tmux session immediately after login or by running:
```bash
$ loginctl enable-linger
```

# Installation

If `apptainer` isn't already installed my admin or you are using HPC platforms (NYCU, NCHC, etc.). You can install yourself.

There are two methods: 

1. Using the official recommended guide: 
https://apptainer.org/docs/admin/main/installation.html#install-unprivileged-from-pre-built-binaries

    **Note**: this method doesn't always work because the target system may be missing `cpio` or `rpm2cpio` packages, which is required by the build script (the build script extracts the directory structure from .rpm file).

2. Using .deb in releases (shown below).

### Using .deb in releases

First, download the released .deb package from the official repo: 

[Apptainer releases (https://github.com/apptainer/apptainer/releases)](https://github.com/apptainer/apptainer/releases)

Then, extract the deb packages and link some directories with below command.

```bash
export APPTAINER_INSTALL_DIR="$HOME/.local/apptainer/"
dpkg-deb --extract "{DEB_YOU_DOWNLOADED}.deb" "$APPTAINER_INSTALL_DIR"
cd "$APPTAINER_INSTALL_DIR/usr/"
ln -s ../etc etc && ln -s ../var var
```

# Usage

## Building apptainer images

You can quickly build an image in the .sif format using the below command. There are arguments in the template that you can tweak🙂.

```
apptainer build -F ub24.sif apptainer-ubuntu24.def
```
**Note: This builds an immutable image, if you want to build a dev container, use below command**

```
apptainer build -F --sandbox containers/sandbox-ub24 apptainer-ubuntu24.def
```
This will build a mutable directory that apptainer can chroot into. However there won't be a sudo command inside of the container so you have to use fakeroot if you want to install packages or do anything requiring root privileges.

Use the below command to enter the container as root and make it writable.
```
apptainer exec --writable --fakeroot containers/sandbox-ub24 bash
```


## Starting a container instance

```
./apptainer_start.sh
```
**Note: When using H100 slurm service from NCHC, you have to additionally bind `/etc/pki/` and `/etc/ssl/` since they use a custom proxy. If not, you may encouter x509 certificate errors when accessing the Internet.**


## Entering a container

```
apptainer shell instance://YOUR_INSTANCE_NAME (e.g. ub24)
```

## Example use case
1. Build the image
2. Start the container
3. Attach to the container
4. Start a tmux session inside of the container and detach the tmux session
5. Leave container
6. Re-attach to the tmux session from the outside
7. Use it just like any tmux session😇 (while the actual context is still inside the container)

## Alternate example use case
1. Build the image
2. Start tmux using the `apptainer_tmux.sh` script
3. Start to do things inside tmux right away or simply detach (tmux will still run)
4. Use it just like any tmux session😇 (while the actual context is still inside the container)
