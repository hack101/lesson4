Hack101 - Lesson 4: Deployment
-------------------------------

One of the things you may have been wondering when we made our flask apps last week is why everyone was on the same IP address and why no one else could actually visit your app. It would appear at `http://127.0.0.1:5000`. The address http://127.0.0.1 is your local computer's address (this address is also known as `localhost`) and `5000` is the port number (where on your computer to find the app). You don't need to connect to the internet to access it because it is just your computer and not part of a network! This is great for developing a website, but it also means that no one else can access you website.

Instead of just running our app on our local computer, we want to run it in a way such that it is visible to any computer that is connected to the internet. To do this we will push it to a server (this just means copy the files to a computer somewhere else and then have people connect to it through that computer).

```
Note:
    Whenever a line is preceded by "➜", I am typing in my terminal
```


## Preparing for Deployment

Currently, when we run our app, it gets hosted at (i.e. becomes accessible from) http://127.0.0.1:5000. If we tried to put this on the web server, it could only be accessed from the web server itself. Pretty useless! This needs to change.


#### Changing the Host

This one is an easy fix. If we want to make the app accessible from other machines, we simply change the host (IP address) to `0.0.0.0`. This address will be accessible to other computers. 

We specify this host by editing the last lines or our app like so:

```python
if __name__ == "__main__":
  app.run(host="0.0.0.0")
```

Now flask knows to run our app at `0.0.0.0`.

![App running at 0.0.0.0](http://s27.postimg.org/j4df05k0j/Screen_Shot_2014_11_03_at_8_22_11_PM.png)

But the port is still `5000`...


#### Changing the Port

The port can be chosen like so:

```python
if __name__ == "__main__":
  app.run(host="0.0.0.0",port=5001)
```

This is great for us to pick a port when we write the app, but we don't know which port the web server will want to use.

Instead of "hard coding" the port, we will set up the app to accept command line arguments from the web server and then tell the web server to give it the port it wants to use when it runs the program. 

We first need to have our python program take a command line argument. We do this by adding the following line to the top of our program

```python
import sys
```

Now that we have imported `sys`, we have access to all the command line arguments as an array of strings in the variable `sys.argv`. The web server will pass the port as the only argument, so we can find it as `sys.argv[1]`. It is `1` and not `0` because `0` refers to the script itself and would have a value `app.py`.

Let's add edit our app so that it can accept a port from the command line. We wil make the last few lines

```python
if __name__ == "__main__":
  port = int(sys.argv[1])
  app.run(host="0.0.0.0",port=port)
```

`int(sys.argv[1])` takes the first argument given to the script and turns it from a string to an integer (which is what we need).

Let's test it out.

![called 'python app.py 5002' and the website is at 0.0.0.0:5002](http://s14.postimg.org/eny71a9td/Screen_Shot_2014_11_03_at_8_35_33_PM.png)

`app.py` is now all ready to be hosted online! Just a recap, this is what our app looks like right now:

```python
import sys
from flask import Flask, redirect, request, url_for, render_template
from firebase import firebase

# config
# server will reload on source changes, and provide a debugger for errors
#DEBUG = True

app = Flask(__name__)
app.config.from_object(__name__) # consume the configuration above

firebase = \
    firebase.FirebaseApplication('https://fiery-torch-8827.firebaseio.com', None)

@app.route('/')
def index():
  return render_template('index.html')

# decorator which tells flask what url triggers this fn
@app.route('/messages')
def messages():
  result = firebase.get('/messages', None)
  return render_template('list.html', messages=result)

@app.route('/submit_message', methods=['POST'])
def submit_message():
  message = {
    'body': request.form['message'],
    'who': request.form['who']
  }
  firebase.post('/messages', message)
  return redirect(url_for('messages'))

if __name__ == "__main__":
  port = int(sys.argv[1])
  app.run(host="0.0.0.0",port=port)
```

I've also commented out the `DEBUG = True` line, seeing as we won't be debugging when it's online!

```sh
➜ git add --all
➜ git commit -m "prepared app.py for deployment"
```

## Heroku

We will be using Heroku to host our website (meaning that they'll let us put our app on one of their servers). This process is somewhat similar to when we used `git push` and sent all of our files to GitHub, except instead of just storing the files, Heroku will run our app and make it available to the internet at an IP address.

To begin, we need to first sign up for [Heroku](https://www.heroku.com/) and then install the [Heroku command line tools](https://devcenter.heroku.com/articles/getting-started-with-python#set-up). Once we we have the command line tools, we will have to login from our computer. It may ask you to generate an ssh key if this is the first time you are logging in. Choose yes.

![Logging into Heroku](http://s8.postimg.org/avdpvk1z9/Screen_Shot_2014_11_03_at_7_21_10_PM.png)



OK great, now we're logged on. Next, lets tell Heroku that we want to create an app.

![Type "heroku create" into the command line](http://s27.postimg.org/t4nh7ee8j/Screen_Shot_2014_11_03_at_8_46_03_PM.png)

Heroku has assigned a random name to my app for me, `intense-scrubland-8501`. This command also created a git repository on the Heroku servers where we will store our website.


When we push our website to Heroku, Heroku will do three things. First, it will try and identify the type of website we just pushed (Python, Ruby, PHP...). Then it will install all the dependencies it needs (in our case, Flask, firebase and requests). Then finally it will look for instructions on how to run the app. 

It recognizes the type of website by looks for certain files. If the website is written in PHP, it looks for an `index.php`. In the case of python, it looks for `requirements.txt`. We already have something similar, but we called it `packages.txt`. Let's rename it now.

```sh
➜ mv packages.txt requirements.txt
```

Next, Heroku will search inside `requirements.txt` and install everything we've listed. 

Finally, it will look for instructions as to how to run the app. We haven't given any yet, so let's do that now.

Heroku will look for a file called `Procfile` and then check it's contents for instructions. 

```sh
➜ touch Procfile # just makes the file
```

And let's open it in Sublime and type the following

```sh
web: python app.py $PORT
```

Now, Heroku will run the command `python app.py $PORT` when we upload our app. `$PORT` is a variable in the Heroku environment and will be the port Heroku wants to use. We're now ready to deploy!

```sh
➜ git add --all
➜ git commit -m "ready for heroku"
➜ git push heroku master
```

This will print a lot of text, and if all goes will should end like this:

![Launching...](http://s17.postimg.org/8fxcng7vz/Screen_Shot_2014_11_03_at_9_08_14_PM.png)

One last thing will be to make sure that the application is actually running and not just sitting on the servers, we type

```sh
➜ heroku ps:scale web=1
```

That's it! Our website is online! We can visit the url printed in the terminal, or just type `heroku open`.

### Viewing Logs

You'll recall that when we had our app running on our computers we could see every request or error message when we ran it, but we don't see anything like that when we push to Heroku, which can make debugging difficult. For example, let's say there was a syntax error in my app.py. How would I get Heroku so say what was wrong?

Let's test out how we would debug. I'm going to remove the colon on the if statement at the bottom of `app.py` (and thus break the website) then push to Heroku.

In `app.py`:
```python
if __name__ == "__main__"
  port = int(sys.argv[1])
  app.run(host="0.0.0.0",port=port)
```

```sh
➜ git add --all 
➜ git commit -m "intentional break"
➜ git push heroku master
```

Everything will look like it's working, but when I try and visit my page, I will see this.


![Application error](http://s9.postimg.org/4fbymlojz/Screen_Shot_2014_11_04_at_12_00_15_AM.png)

To solve the problem, I check the logs (the equivalent of what was begin printed to our terminal)

```sh
➜ heroku logs
```

![Syntax error](http://s14.postimg.org/lc776zinl/Screen_Shot_2014_11_04_at_12_04_11_AM.png)

These logs tell us that the server tried to run `python app.py 59896` (I guess in this case `$PORT` was `59896`), but encountered a syntax error at line 34. Great, so now I can fix the problem.

Obviously this isn't a very realistic example. I would me sure to test my site locally before I put it online so that things like this don't happen.

### Getting a domain for our site

Right now, we have been given a domain by Heroku (intense-scrubland-8501.herokuapp.com) for me, but what if we want to use our own domain name? 

Let's get something more personal...

[Namecheap](https://nc.me/) is currently offering free domain names for students! Go ahead and grab one. 

Now we want it so that when people use visit our domain it displays our website. There are two steps to this. 

1. As the owner of the Heroku app, say we want to let our new domain point to our site.
2. As the owner of the domain, say we want our domain to point to our site.

Both these steps are very simple. We will do them then explain how they work after

##### 1: Heroku

Telling Heroku to add a domain is simply done with one command

```sh
➜ heroku domains:add <domain>
```

For me, it was `heroku domains:add amielkollek.me` and `heroku domains:add www.amielkollek.me`, since I want both these to take me to my site.

##### 2: Namecheap

When a user types in a url, the address of the computer that is sending them information is a series of numbers and is meaningless to a human. So, we have the Domain Name System (or DNS) which acts as a "phone book" and let's me see Google by typing "www.google.com" rather than having to type in a Google server's IP address. What we are about to do is edit that phone book and tell it to direct our domain to our new site.

Log into [Namecheap](https://www.namecheap.com/) then click domains. Click on your new domain. In the left bar, you will see an option under "Host Management", "URL Forwarding". Click this, and in the "@" and "www" sections, put you app's URL in the IP/URL field, then choose CNAME (Alias) in the drop down. You will also see a field on the right, "TTL". This stands for time to live. It is how long it will be between refreshes of this DNS entry. It will likely start out as half an hour for you, meaning you may have to wait for half an hour before you will be able to see your Heroku site at your domain. I am going to change it to 60 (the smallest allowed) so that in the future it will be faster. We'll still have to wait half an hour for this firs time though...

![final namecheap configuration](http://s29.postimg.org/cuhoi47xz/Screen_Shot_2014_11_04_at_12_55_00_AM.png)

-----
And we're all set! Our website will be online and visible to everyone in the world!


### Continuing development


So we're online! Awesome! What if we want to change something on our site now though? Playing around and changing the site wasn't a problem before, since we were only working on our own computer. Now, however, we are editing the code of a live website. If we break the website and push to heroku, we should see our site go down!

Of course, if we broke the site we wouldn't push until it was fixed, but lets say that you begin making some major changes to the site, and half way through you realize that there's a typo on your main page. You'd have to either finish your major changes before you could push to Heroku to fix the typo, or revert you code (using git) to an older working version, fix the typo, push to Heroku, then continue working on your big change. This seems overly difficult, so let's not do that!

Git has us covered in this situation with "branching". Branching lets you create a copy of your code, edit it, then switch back and forth between different copies. So far we have only been working on one branch (the "master" branch), and this is the branch that we are sending to Heroku.

How would we use branching in the example above? Before we started making an changes, we would create a new branch called "big-change". We could work on this branch to our heart's content and not worry about breaking anything. When we noticed the typo, no problem! We could just switch to "master", fix the typo, push to Heroku, then switch back to "big-change" and keep working. Easy!

Let's do an example of branching now. Currently my main page says:

```
Hello, my name is Amiel. I study math and physics at McGill university and I am going to make my own website!
```

This is no longer true though! I have made my own website! Let's fix it.

I'll start by making a new branch

```sh
➜ git checkout -b fixing-header
```

The git command `checkout` is used to switch between branches, and the `-b` tells it I want to make a new one. Now that I'm on the "fixing-header" branch I can edit things without fear of breaking anything. Let's fix that line in `templates/index.html`. I'll change it to

```
Hello, my name is Amiel. I study math and physics at McGill university and I made my own website!
```

I run it locally and see that all is in order. Great.

```sh
➜ git add --all
➜ git commit -m "updated header"
```

Now I can switch back to master to put it on Heroku.

```sh
➜ git checkout master
```

But wait, I made my changes in "fixing-header", so "master" hasn't changed. To take the changes made in "fixing-header", I merge the two branches.

```sh
➜ git merge fixing-header
```

This command is saying, take the changes made in "fixing-header" and merge them into my current branch (in this case "master"). Git will try and merge the two branches. Since "fixing header" is one commit ahead of "master", the merge is easy and git does it automatically. There are cases however where it is no so easy and git will ask you to manually fix conflicts (for example if I changed the same line in two branches to then tried to merge the branches, git would have to ask which line I wanted to keep).

Another great use of branches is if multiple people are working on code. I can make a branch to write my code and not worry about interfering with the other programmer, as we can just merge our branches when we are both done. 

OK, so our fix was applied to "master" and we can update the live site!

```sh
➜ git push heroku master
```





