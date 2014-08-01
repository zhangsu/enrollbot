# Enrollbot

Bot that automates the process of trying to get into a course during open enrollment at the University of Waterloo. Simply leave Enrollbot running and it will keep trying to enroll for you on Quest until success.

--------------------------------------

## Prerequisite

Enrollbot runs on Node.js, but not all required modules can be install by NPM.

### PhantomJS
Enrollbot uses PhantomJS, which is not a node module. There is a couple of ways to install it.

#### Install it by [downloading the official binary](http://phantomjs.org/download.html)
You need to make sure that the binary is in your PATH environment variable.

#### Install through native package manage
##### Arch

```
pacman -S phantomjs
```

##### Ubuntu
```
apt-get install phantomjs
```

### CasperJS and other node modules
These will be installed when you do
```
npm install
```

### Must be run during open enrollment
Enrollbot is a simple bot that only works during open enrollment. Enrollbot should only be needed during this time window because this is the only time window that the courses might be full and you can still enroll. During open enrollment, you enroll into a course as follows:
Login -> Click "Enroll" -> Click "add" -> Choose term -> Click "Continue" -> (Add courses into your cart) -> Click "Proceed to Step 2 of 3" -> Click "Finish Enrolling".

### Must have your cart ready
Currently, Enrollbot only supports a simple procedure of enroll into the courses in your cart. The courses you want to add must be pre-added to your cart before running Enrollbot.

--------------------------------------

## Use
There is a step of choosing the term in a term table when you enroll on Quest, identified by a zero-based index, e.g., 0 for the first term in the table, 2 for the third term in the table). By default, Enrollbot chooses 1 because there are usually only two terms in the table with the first one being the current term and the second one being the next term, and you are more likely to enroll for the next term.

You can also customize delay times. The delay variation time v is an upper limit for a random amount of time added to or subtracted from the delay base time b, which makes your enroll requests on Quest look less robotic and more random.
The actual delay time between retries is a random number in the interval [b - v, b + v).

Set the delay time to a reasonable high value to prevent DoS attack on Quest. You will get banned (or at least audited) by the admin if your request frequency is too high and start DoSing Quest.

Run with default configuration that chooses the second term in the term table
```
node_modules/coffee-script/bin/coffee bot.coffee
```

Choose the first term in the table:
```
node_modules/coffee-script/bin/coffee bot.coffee --term=0
node_modules/coffee-script/bin/coffee bot.coffee -t 0
```

Run with custom delay base time between retries, in mins (30 mins in this case):
```
node_modules/coffee-script/bin/coffee bot.coffee --base=30
node_modules/coffee-script/bin/coffee bot.coffee -b 30
```

Run with custom delay variation time between retries, in mins (5 mins in this case):
```
node_modules/coffee-script/bin/coffee bot.coffee --var=5
node_modules/coffee-script/bin/coffee bot.coffee -v 5
```

### Credential
Upon running Enrollbot, you will be prompted for entering your quest id and password. If you are paranoid about this, check out the source code and make sure Enrollbot is not a keylogger. Password you typed won't be echoed in the terminal.

You can save your Quest userid in `credential.yml` to save your from entering it everytime you run Enrollbot. You only need to enter your credential once per running session, i.e., no need to do it between enroll tries happened in the same bot process.

### Result
Enrollbot terminates when it thinks the enrollment is successful, or it continues if it thinks the enrollment is failed. In either cases, a `quest.png` screenshot of the final result page is taken in each trial run.
