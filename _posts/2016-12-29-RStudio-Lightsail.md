---
layout: post
title:  "How to Setup RStudio on Amazon Lightsail"
desc: "Setting up "
keywords: "r,lightsail,vps,rstudio"
date: 2016-12-27
categories: [R]
tags: [R]
icon: fa-bookmark-o
---

*[This post is based on the guide from [SAS and R](http://sas-and-r.blogspot.com/2016/12/rstudio-in-cloud-with-amazon-lightsail.html)]*

In this post we'll use the new [Amazon Lightsail](https://lightsail.aws.amazon.com/) to create an always-on RStudio enviornment in the cloud. With a older Macbook Air, the migration from local to cloud data processing and analysis allowed me to forget about resource constraints.

<img style="border:1px solid #000000;display: block;margin-left: auto;margin-right: auto;" src="{{site.img_path}}/lightsail/lightsail_0.gif" width="600px">

# Setup Lightsail Instance

Lightsail is Amazon's virtual private servers (VPS) offerring that make spinning up a workspace in the cloud a breeze. In contrast to EC2, there is little provisioning involved and the pricing is "no-nonsense" (aka transparent). You'll notice that the interface is significantly more user-friendly than the EC2 Dashboard.

(1) Login into [Amazon Lightsail](https://lightsail.aws.amazon.com/) and create a new instance.

<img style="border:1px solid #000000;display: block;margin-left: auto;margin-right: auto;" src="{{site.img_path}}/lightsail/lightsail_1.png" width="900px">

(2) Select **Base OS** and **Ubuntu**

<img style="border:1px solid #000000;display: block;margin-left: auto;margin-right: auto;" src="{{site.img_path}}/lightsail/lightsail_2.png" width="400px">


(3) I encourage you to use public key rather than a key from Amazon for ease of SSH'ing to your VPS. If you're on OSX, you public key is likely in


```
~/.ssh/id_rsa.pub
```

If you haven't setup a SSH key yet, use [Github guide](https://help.github.com/articles/generating-an-ssh-key/).

For some reason, Amazon makes this difficult by using a regular file browswer. You need to make hidden files viewable in Finder by running

```
defaults write com.apple.finder AppleShowAllFiles YES
killall Finder
```

Finder will automatically relaunch. Navigate to ```~/.ssh``` and drag that into the **Upload a key pair** Choose file dialog. Once the key pair is uploaded, run the following commads to hide hidden files and folder in Finder.

<img style="border:1px solid #000000;display: block;margin-left: auto;margin-right: auto;" src="{{site.img_path}}/lightsail/lightsail_3.gif" width="600px">

```
defaults write com.apple.finder AppleShowAllFiles N
killall Finder
```

(4) Select the $5/month plan (that comes with a month free), name your instance anything (I chose *RStudio*), and click **Create**

<img style="border:1px solid #000000;display: block;margin-left: auto;margin-right: auto;" src="{{site.img_path}}/lightsail/lightsail_4.png" width="500px">
 
(5) While you're waiting for the server to spin up, click the 3 dots in the upper-right and selected **Manage**. On the **Networking** tab, under the **Firewall** table, click **+Add Another**. Leave *Custom* and *TCP*, but change the range to just **8787**. This will be the port we connect to the RStudio interface.

<img style="border:1px solid #000000;display: block;margin-left: auto;margin-right: auto;" src="{{site.img_path}}/lightsail/lightsail_5.png" width="500px">

(6) After the instance is **Running**, SSH into the server using the public IP address in the corner (don't worry this one has been deleted).

<img style="border:1px solid #000000;display: block;margin-left: auto;margin-right: auto;" src="{{site.img_path}}/lightsail/lightsail_6.png" width="500px">

```
ssh ubuntu@54.209.145.59
```

Say ```yes```  to the recognition of your SSH key. You are now connected!   

# Swap Space

Installing some R packages can be very memory intensive, including the [tidytext](https://cran.r-project.org/web/packages/tidytext/index.html) package and the Lightsail VPS has only 512MB of memory. In order to make installations possible, we need to use swap space. Swap space is a portion of virtual memory that is on the hard disk, used when RAM is full. Luckily the base tier has a 20GB SSD. These sets comes from a great [DigitialOcean tutorial](https://www.digitalocean.com/community/tutorials/how-to-configure-virtual-memory-swap-file-on-a-vps).

Run on the VPS to see that currently there is no swap memory.

```
free -h
```

<img style="border:1px solid #000000;display: block;margin-left: auto;margin-right: auto;" src="{{site.img_path}}/lightsail/lightsail_7.png" width="500px">

Run the following commands to create a swap file called **swap.img**, size it to be 2GB (2048k) and turn it on.

```
cd /var
sudo touch swap.img
sudo chmod 600 swap.img
sudo dd if=/dev/zero of=/var/swap.img bs=2048k count=1000
sudo mkswap /var/swap.img
sudo swapon /var/swap.img
```

Now run to see the 2GB is now space space.

```
free -h
```

<img style="border:1px solid #000000;display: block;margin-left: auto;margin-right: auto;" src="{{site.img_path}}/lightsail/lightsail_8.png" width="500px">

# Rocker

(1) Download [Docker](https://www.docker.com/) by running and clicking **Y** to install.

```
sudo apt-get install docker.io
```

(2) Start the Docker service by running

```
sudo service docker start
```

(3) Run the following command to start the Rocker file.

```
sudo docker run -d -p 8787:8787 -e ROOT=TRUE rocker/hadleyverse
```

The first time, there will need to be a download and extraction.

In the run command above

+ -d indicates the container starts in detached mode
+ -p publishes a container᾿s port to a port on the host (allowing us to use 8787 to access RStudio in the browser)
+ -e sets an enviornment variable, in our case enabling root access

(4) In the browser, navigate to <VPS IP address>:8787. Username = rstudio and password = rstudio. 

<img style="border:1px solid #000000;display: block;margin-left: auto;margin-right: auto;" src="{{site.img_path}}/lightsail/lightsail_9.png" width="350px">

(5) You're using RStudio in the cloud!

<img style="border:1px solid #000000;display: block;margin-left: auto;margin-right: auto;" src="{{site.img_path}}/lightsail/lightsail_10.png" width="500px">

# Rocker Usage

## Installing Packages

You are going to want to customize your docker container for future R-ing. Let's bookmark the webpage and get started. Install your favorite packages (some that use g++ will take a bit longer but will finish thanks to the swap memory). Change RStudio settings. 

If there are external dependencies (i.e. for [Rattle](https://cran.r-project.org/web/packages/rattle/index.html)) you need to install them in the docker container. Let's do this for Rattle:

(1) View active containers

```
sudo docker ps
```

<img style="border:1px solid #000000;display: block;margin-left: auto;margin-right: auto;" src="{{site.img_path}}/lightsail/lightsail_11.png" width="500px">

(2) Start bash shell for the container

```
sudo docker exec -it <container-id> bash
```

(3) Install libgtk2.0-dev, typing **Y** after the second command

```
sudo apt-get update
sudo apt-get install wajig 
sudo wajig install libgtk2.0-dev
```

## Saving an Container

You do not need to close the Docker container, but it's a good idea to save the container once you have it in a place you'd like.

To the save your current container, find the container id and run the commit command

```
sudo docker ps
sudo docker commit -m "tidyverse + my packages" <container id>  rstudio2
```

To see all images

```
sudo docker images
```

<img style="border:1px solid #000000;display: block;margin-left: auto;margin-right: auto;" src="{{site.img_path}}/lightsail/lightsail_12.png" width="400px">

You should see **rocker/hadleyverse** and your new container. Now, kill your original container and start the new one. The command below actually kills all open containers.

```
sudo docker stop $(sudo docker ps -a -q)
```

Then start your newly saved container:

```
sudo docker run -d -p 8787:8787 -e ROOT=TRUE rstudio2
```

# Headless Dropbox

I found that this setup was not too useful less I had data transfer to the Docker container running RStudio. A good solution here is Dropbox. All my work is stored in Dropbox and I have a Dropbox account that runs on an EC2 instance and downloads course data from [Canvas](https://www.canvaslms.com/), the learning management system my university uses every half-hour. So, if my professor added an new .R file or dataset, I immediately had access in RStudio in the cloud. 

## Install Python2.7

(1) Install a bunch of dependencies:

```
sudo apt-get update
sudo apt-get install build-essential checkinstall
sudo apt-get install libreadline-gplv2-dev libncursesw5-dev libssl-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev
```

(2) Download and extract python2.7

```
wget https://www.python.org/ftp/python/2.7.12/Python-2.7.12.tgz
tar -xvf Python-2.7.12.tgz
cd Python-2.7.12
```

(3) Perform the installation. For the last line ```checkinstall```, you'll need to respond to a lot of question and it will take a bit.

```
./configure
make
sudo checkinstall
```

(4) Check that the default python version is now 2.7

```
python -V
```

<img style="border:1px solid #000000;display: block;margin-left: auto;margin-right: auto;" src="{{site.img_path}}/lightsail/lightsail_13.png" width="200px">

## Install Dropbox

(1) Download and start the daemon

```
cd ~ && wget -O - "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xzf -
~/.dropbox-dist/dropboxd
```

After the last command you'll see

<img style="border:1px solid #000000;display: block;margin-left: auto;margin-right: auto;" src="{{site.img_path}}/lightsail/lightsail_14.png" width="400px">

Take the URL and paste it into the browser to connect to your Dropbox account.

<img style="border:1px solid #000000;display: block;margin-left: auto;margin-right: auto;" src="{{site.img_path}}/lightsail/lightsail_15.png" width="450px">

(2) Download dropbox's python script to control dropbox

```
mkdir -p ~/bin
wget -O ~/bin/dropbox.py "https://www.dropbox.com/download?dl=packages/dropbox.py"
chmod +x ~/bin/dropbox.py
python2.7 ~/bin/dropbox.py start
python2.7 ~/bin/dropbox.py autostart y
```

You'll now see the Dropbox folder in your **ubuntu** directory.

## Run Docker Container with Dropbox

Now with Dropbox set up, you can use the -v switch to attach the Dropbox folder to your Docker container. 

```
sudo docker run -d -e ROOT=TRUE -v /home/ubuntu/Dropbox:/home/rstudio/Dropbox -p 8787:8787 rstudio2
```

Now, you can see the Dropbox folder in the **Files** pane.

<img style="border:1px solid #000000;display: block;margin-left: auto;margin-right: auto;" src="{{site.img_path}}/lightsail/lightsail_16.png" width="500px">






