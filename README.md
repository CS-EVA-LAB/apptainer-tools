# Apptainer-tools

Apptainer is an alternative to docker or podman. It's essentially container tech for HPC. 

# Usage

## Building apptainer images

You can quickly build an image using the below command. There are arguments in the template that you can tweak🙂.

```
apptainer build -F ub24.sif apptainer-ubuntu24.def
```
**Note: This builds an immutable image, if you want to build a dev container, use below command**

```
apptainer build -F --sandbox sandbox-ub24 apptainer-ubuntu24.def
```
This will build a mutable directory that apptainer can chroot into. However there won't be a sudo command inside of the container so you have to use fakeroot if you want to install packages or do anything requiring root privileges.

Use the below command to enter the container as root and make it writable.
```
apptainer exec --writable --fakeroot sandbox-ub24
```


## Starting a container instance

```
./apptainer_start.sh
```

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
