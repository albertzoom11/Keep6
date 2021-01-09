## Inspiration

Without a doubt, the most pressing global issue right now is the fight against COVID-19. Currently the battle against this global pandemic is fought on two fronts. While our healthcare heroes seek to end the disease one patient at a time, the rest of us must do our part to keep the global community safe and healthy. All across the world, people are quarantining themselves and practicing social distancing when going outside. According to the Center for Disease Control and Prevention, social distancing is defined by two main parts: not gathering in groups and staying at least 6 feet apart. With people still leaving their houses, whether to run essential errands or just to exercise, it becomes near impossible to keep track of everybody that has come near you. We wanted to create a widespread platform for people to be able to track the coronavirus status of the people that they have come near through factors like recency of interaction, proximity of interaction, and latest COVID-19 testing results.

## What it does

Keep6 is a mobile app, Arduino hardware, and website based platform that encourages and monitors safe social-distancing. Using an RFID sensor, the platform is able to track the distance from the user to the other people around them. An ESP8266 module is then used for communication to a server which will log the distances and communicate them with the mobile app and website. The mobile app is used to determine whether the user has been within 6 feet of anyone and would therefore be at risk, while the website displays a Google Maps API detailing the most concentrated areas of people to avoid.

## How we built it

###Hardware

 We used an Arduino Mega with an MFRC522 module for RFID distance functionality and an ESP8266 module for public server communication. A portable device was made for users to carry with them in their outdoors excursions. These RFID sensors are used to track the proximity of neighboring users and relay that to a server. Compared to Bluetooth and GPS location services, RFID distancing is accurate to the foot and has a very large range. Furthermore, because RFID is secure, does not track users’ data or absolute location, and only returns relative distances with other users, there are no privacy concerns for the user.

###Server

The server is the middleman for the entire project. It handles all requests coming in from the arduino, iphone app, and the website. The first process that the server handles is users logging and signing in. From there the server gets a request from the arduino to update the device location. This information is then sent to a web socket that the iphone also connects to in order to view the location of other arduino devices in the area. The server then calculates the distance between devices in order to determine whether the user is within 6 feet of another user.

###App

We created the app using the Flutter programming language and it allows you to connect to your RFID reader. This app will allow you to see if you are near someone else and notify you of your risk of COVID and the distance between you and the closest person. It also gives the user the option to set whitelists for people that are in their family by adding their email addresses. The app collects information on whether or not the user has been diagnosed with COVID-19 and accordingly updates the risk levels for those around them. All of the app communications are routes through the server to enhance security.

###Website

We created the website using a Google Maps API paired with javascript code marking concentrated areas of people on the map. HTML/CSS was used for the formatting of the website which allows user login to view the personal coronavirus information in the form of maps and tables that is obtained through the server.

## Challenges we ran into

We ran into numerous problems with wiring/programming the Arduino hardware for sensor reads and Wi-Fi communication. We were originally using a NodeMCU, but found out that it cannot handle Wi-Fi communication and RFID read simultaneously because of serial port limitations. After switching to the Arduino Mega and debugging server request issues, we were able to seamlessly implement the hardware. Furthermore, we had some issues with whitelist users on the backend because of the multiple links required for its functionality. However, we were able to develop a reliable algorithm for editing and parsing the storage structure to provide this functionality with no errors or miscommunications.

## Accomplishments that we're proud of

We are especially proud that we were able to accomplish seamless Wi-Fi based server communication between 4 distinct components. Each of our 4 team members took on a component and worked together to mesh each piece together into a single, connected platform. With all of the user information, RFID identifiers, distances, and other data points that are passed between components as API parameters, we are proud that we created a platform that handles it all accurately and efficiently, all while working remotely.

## What we learned

This was our first hackathon in a remote setting, so we had to learn to collaborate with each other through voice calls and coding live shares. While it was difficult at times to work on frontend/backend integration and hardware communication with other components, we were able to complete all of the functionality we originally envisioned. 

## What's next for Keep6

A potential next step for Keep6 would be to find a medically approved algorithm to determine the likelihood of infection for the user based on the data that the Keep6 server already tracks. Another important step to maximizing the effectiveness of this platform would be to expand to as many users as possible so that the server has more information. One way of doing this would be to make the RFID Arduino mechanism smaller and more convenient for users to carry around so that they would be more incentivized to use it.
