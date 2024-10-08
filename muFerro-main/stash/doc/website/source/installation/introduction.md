---
title: Installation and setup
---

## Prerequisite
muferro is built with Intel parallel studio cluster edition, and Intel mpi is required to run the program. Make sure the **$LD\_LIBRARY\_PATH** is correctly configured that the folder containing shared library **libmpi.so.12** and **libmpifort.so.12** must be presented. These two library should be found in the Intel mpi distribution folder, for example, on the Penn State ACI-ICS server, it is located at **/opt/intel/compilers\_and\_libraries_2016.3.210/linux/mpi/intel64/lib**. 
Another dependency is the mpi version of fftw library, we need the **libfftw3\_mpi.so.3** and **libfftw3.so.3** shared library. Make sure the fftw library is compiled with intel compiler and intel mpi instead of gcc compiler.

To add an additional path to **$LD\_LIBRARY\_PATH**, you would use the **export** command.

```sh
export LD_LIBRARY_PATH=/YOUR/OWN/PATH:$LD_LIBRARY_PATH
```


## Installation
To install and use the program is simple, all you need to do is copy the *muFerro* file to your server and change the permission of the file to be executable. Notice here the file extension exe does not mean it is a Window's program. The *muFerro* is a linux executable, the extension is to differentiate it from other text files.

## Request License File
Please contact us at mesoscale-modeling@mupro.co for a quote or trial license to get started.

In order to register your copy of the program, we need the following information:
1. **hostname**. Be careful that this may not be the host name you used to get access to your linux server, but the host name of the login node. For example, I can connect to the Penn State server through `ssh xuc116@aci-b.aci.ics.psu.edu`, but there are multiple login nodes, I'm actually connected to a node called **aci-004.aci.production.int.aci.ics.psu.edu**. This is the host name you should provide to us, rather than the **aci-b.aci.ics.psu.edu** one. If there are multiple host names, a list should be provided. You can easily obtain the hostname of your server or computer by execute `echo $HOSTNAME` in the linux terminal.
2. **username**. The user name you want to grant access to use *muferro*. You can find the user name by typing `echo $USER` in the terminal. Note if you apply for the group license rather than individual one, you should provide the group name instead of user name.
3. **group name**. The group of users that you want to grant access to use *muferro*. You can find all of the group you belong to by executing the **id** command in terminal.
4. **ip address**. You can obtain your server's ip address by typing `curl ipinfo.io/ip` in terminal. Same as hostname, if there are more than one ip address that you may get connected to, provide us with a list of them.

test \cite{gregor2015draw}


<bibliography>
@article{gregor2015draw,
    title={DRAW: A recurrent neural network for image generation},
    author={Gregor, Karol and Danihelka, Ivo and Graves, Alex and Rezende, Danilo Jimenez and Wierstra, Daan},
    journal={arXivreprint arXiv:1502.04623},
    year={2015},
    url={https://arxiv.org/pdf/1502.04623.pdf},
}
</bibliography>