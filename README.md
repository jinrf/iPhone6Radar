# iPhone 6 Radar
## Why "iPhone 6 Radar"?
###The Pain
If you want to buy an iPhone 6/6+ without renewing contract, you know the pain. Since the release in September, iPhone 6 and iPhone 6 plus are incredibly hard to find at your local Apple Stores. Let alone choosing storage size and your favorite color!

###iPhone 6 Radar
I had the same pain. So I created this iPhone app to track availabilities of iPhone 6/6+ in Apple Stores nearby. Simply add phones to the wish list by model, carrier, color and storage size. Once they are in stock in nearby Apple Stores, realtime notifications and email updates will be sent automatically. 

###My Result
With the help of the app, I successfully grabbed one iPhone 6 at San Francisco Bay Area, and one iPhone 6 plus in Las Vegas while I was on a road trip! :-D That's why I call it "**The Ultimate iPhone 6/6+ Tracking Tool**".

###Screenshots

![](https://)

##Features

* **Realtime Notification:** Never miss an opportunity again! Simply add the models you want to the wish list. Once they are in stock, push notifications will be immediately sent to you. Emails will also be sent with more details about where to buy. 

* **Location Tracking:** Track iPhone 6/6+ anywhere! if you drives a lot or on a trip, the app will automatically check iPhone 6/6+ inventories around you to maximize your chance to snap one.

* **Detail Apple Store List:** For each iPhone 6/6+ available, a list of in-stock Apple Stores are provided, along with each store's address, phone number, store hours and driving direction. 

##How To Use It?
Unfortunately, because this app scraps Apple Online Store to get realtime inventory information, Apple won't allow this app in their App Store according to the review guideline section 12.1:

> 12.1: Apps that scrape any information from Apple sites (for example from apple.com, iTunes Store, App Store, iTunes Connect, Apple Developer Programs, etc.) or create rankings using content from Apple sites and services will be rejected.

That's why I am posting it here for anybody who wants to buy an iPhone 6 but couldn't get one. 

### How To Install
To install the app on your iPhone, you need to:

1. Have an active iOS developer membership. If you don't have one, ask your friends for help. 
2. Create a development provisioning profile for this app in the [Apple Developer Member Center](https://developer.apple.com/). 
3. Then checkout out the code, build and install. 
4. And feel free to fork for your own use.

### A Few Notes

* Currently this app only checks iPhone 6 inventory in the United States.
* To always check the nearest Apple Stores, this app tracks location at background. Location tracking also keeps the background fetch timer live. **The location information is only used for checking Apple Store inventory and never sent to anywhere.** 
* All realtime notifications are sent as local notifications. So no need for additional push notification servers. 
* Email updates were sent by SendGrid. But I had to remove my SendGrid account information when it is made open source. To keep the email notification function working, your own Gmail account is used to send notification emails. That's why the app asks for you email password if you choose to receive email notifications. **Your password is saved only on your phone (as clear text) and never sent to anywhere. You can always create a temporary Gmail account for the notification purpose if that makes you more comfortable.**
* Currently email notification only supports Gmail accounts.

##To-Dos
1. Also check iPhone inventories for 3rd party stores, such as BestBuy, AT&T, Verizon, ...
2. Support more countries.
3. Check inventory information for all Apple Store products.

##Acknowledgement
This app uses several thrid party opensource packages, including:

1. [AFNetworking]()
2. [SMTPLibrary]()
3. [CSNotificationView]()
4. [UIColor+HexString]()
5. [UIColor+iOS7Colors]()

##License
**This software is licensed under MIT License.**

Copyright (c) 2014 clingmarks.com

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
