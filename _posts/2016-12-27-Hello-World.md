---
layout: post
title:  "How to Setup RStudio on AWS Lightsail"
desc: "Hello World"
keywords: "hello,world"
date: 2016-12-27
categories: [R]
tags: [R]
icon: fa-bookmark-o
---

In this post we'll use the new [Amazon Lightsail](https://lightsail.aws.amazon.com/) to create an always-on RStudio enviornment in the cloud. With a older Macbook Air, the migration from local to cloud data processing and analysis allowed me to forget about resource constraints.

<>

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

<img style="border:1px solid #000000;display: block;margin-left: auto;margin-right: auto;" src="{{site.img_path}}/lightsail/lightsail_9.png" width="500px">

(5) You're using RStudio in the cloud!

<img style="border:1px solid #000000;display: block;margin-left: auto;margin-right: auto;" src="{{site.img_path}}/lightsail/lightsail_10.png" width="500px">

# Rocker Usage

To see all images

```
sudo docker images
```

To view active containers

```
sudo docker ps
```

# Headless Dropbox






