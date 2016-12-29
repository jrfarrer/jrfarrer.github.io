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

1. Login into [Amazon Lightsail](https://lightsail.aws.amazon.com/) and create a new instance.

![alt-text]({{ site.img_path }}/lightsail/lightsail_1.png 'Title text')

2. Select **Base OS** and **Ubuntu**

![alt-text]({{site.img_path}}lightsail/lightsail_2.png 'Title text')

3. (Optional) I encourage you to use public key rather than a key from Amazon for ease of SSH'ing to your VPS. If you're on OSX, you public key is likely in

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

```
defaults write com.apple.finder AppleShowAllFiles N
killall Finder
```

4. Select the $5/month plan (that comes with a month free), name your instance anything (I chose RStudio), and click **Create**


 
# Swap Memory


# Require Packages


# RDocker

# RDocker






