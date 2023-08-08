// controller/chatbot.js
const AWS = require('aws-sdk');
const natural = require('natural');
const docClient = new AWS.DynamoDB.DocumentClient();
const tableName = 'brainwave-chat';
const classifier = new natural.BayesClassifier();
const fs = require('fs');
const path = require('path');
function trainClassifier() {

  const trainingData = require('./training_data.json');

  for (const data of trainingData) {
    classifier.addDocument(data.question, data.category);
  }

  classifier.train();
}


function processMessage(message) {
  const classification = classifier.classify(message);
  console.log(classification);

  const decisionMap = {
    'personal': makePersonal,
    'greetings': makeGreetingDecision,
    'location': getCurrentLocationDecision,
    'identity': makeIdentityDecision,
    'fun': makeFunDecision,
    'programming': () => {
      const programmingLanguage = extractKeyWords(message);
      return makeProgrammingDecisions(programmingLanguage);
    },
    'web development': () => {
      const webDevelopment = extractWebKeywords(message);
      return makeWebDecisions(webDevelopment);
    },
  };

  const response = decisionMap[classification] ? decisionMap[classification]() : getDefaultResponse();

  return response;
}

function getDefaultResponse() {
  return `As an AI language model, I don't have access to real-time information about the state of your program or its execution. However, based on the code you provided, I can help you identify potential issues and suggest possible solutions.`;
}

function makePersonal() {
  const personal = [
    "That's so sweet! 😍 I appreciate your kind words, even though I'm an AI and don't have the ability to experience love. Is there anything else I can assist you with?",
    "Love is a beautiful and powerful emotion that can bring immense joy and fulfillment.",
    "Love knows no boundaries and has the power to unite people from different backgrounds and cultures.",
    "True love is built on trust, understanding, and mutual respect.",
    "Love can be both exhilarating and challenging, but it is worth the journey.",
    "Love is not just about romantic relationships; it also includes the love we have for our family and friends.",
    "Love is a language that transcends words and is expressed through actions and gestures.",
    "The feeling of being loved and cared for is one of the greatest joys in life.",
    "Love requires effort, patience, and commitment to make it thrive.",
    "Love can inspire us to become better versions of ourselves and bring out our true potential."
  ];


  const randomIndex = Math.floor(Math.random() * personal.length);
  return personal[randomIndex];
}



function makeGreetingDecision() {
  const greetings = [
    `Hello, it's great to see you!'`,
    `Hi there, how have you been?`,
    `Warm greetings to you, my friend!`,
    `It's a pleasure to meet you, welcome!`,
    `Hey, how's your day going so far?`,
    `'Howdy, hope you're having a fantastic day!'`,
    `'Salutations! Wishing you a wonderful time!'`,
    `'Good day! May your journey be filled with joy!'`,
    `'Hola! Qué tal? Espero que tengas un gran día!'`,
    `'Welcome! I hope you feel right at home here.'`,
    `'Hey, how are you doing today? Anything exciting happening?'`,
    `'Greetings and salutations! How can I brighten your day?'`,
    `'Hey, it's lovely to cross paths with you!'`,
    `'Hi, hope you're enjoying the beautiful moments of life!'`,
    'Warmest greetings! Ready to make some memories?',
    `'Hey there, ready for an amazing adventure?'`,
  ];

  const randomIndex = Math.floor(Math.random() * greetings.length);
  const greeting = greetings[randomIndex];

  return greeting;
}


function getCurrentLocationDecision() {
  let response;

  if (userLocation) {
    response = 'Your current location is ' + userLocation;
  } else {
    response = 'I am sorry, I could not determine your current location.';
  }

  return response;
}

function makeIdentityDecision() {
  const currentHour = new Date().getHours();
  let response;

  if (currentHour < 12) {
    response = 'Good morning! I am an AI chatbot.';
  } else if (currentHour < 18) {
    response = 'Good afternoon! I am an AI chatbot.';
  } else {
    response = 'Good evening! I am an AI chatbot.';
  }

  return response;
}

function makeFunDecision() {
  const jokes = ["Why don't scientists trust atoms? Because they make up everything!", "What do you call a fish wearing a crown? King Neptune.", "Why don't skeletons fight each other? They don't have the guts.", "What did one wall say to the other wall? 'I'll meet you at the corner.'", "Why did the scarecrow win an award? Because he was outstanding in his field.", "How do you make a tissue dance? You put a little boogie in it.", "Why don't eggs tell jokes? Because they might crack up.", "What's brown and sticky? A stick.", "What did one plate say to the other plate? Dinner is on me!", "Why don't scientists trust stairs? Because they're always up to something."];

  const randomIndex = Math.floor(Math.random() * jokes.length);
  return jokes[randomIndex];
}


function makeProgrammingDecisions(programmingLanguages) {
  const decisionMessages = [];
  try {
    const file = require('./response.json');
    const languageDecisions = file.languageDecisions;

    for (let i = 0; i < programmingLanguages.length; i++) {
      const language = programmingLanguages[i];
      console.log(language);
      if (language in languageDecisions) {
        const decisions = languageDecisions[language];
        console.log(decisions);
        const randomIndex = Math.floor(Math.random() * decisions.length);
        console.log(randomIndex);
        decisionMessages.push(decisions[randomIndex]);
        console.log(decisionMessages);
      } else {
        decisionMessages.push('Programming is the process of giving instructions to a computer to perform specific tasks by writing code in programming languages.');
      }
    }

    return decisionMessages;
  } catch (err) {
    console.log('the error is ' + err);
    console.log(err.message);
  }
}


class TrieNode {
  constructor() {
    this.children = new Map();
    this.isEndOfWord = false;
  }
}

function buildTrie(keywords) {
  const root = new TrieNode();
  for (const keyword of keywords) {
    let node = root;
    for (const char of keyword) {
      if (!node.children.has(char)) {
        node.children.set(char, new TrieNode());
      }
      node = node.children.get(char);
    }
    node.isEndOfWord = true;
  }
  return root;
}

function extractKeyWords(message) {
  if (!message) {
    return [];
  }

  const keywords = require('./checking_data.json');
  const programmingLanguagesTrie = buildTrie(keywords.languageDecisions.map(keyword => keyword.toLowerCase()));

  const words = message.toLowerCase().split(/[ ,.?!-]+/);
  const languages = new Set();

  for (let i = 0; i < words.length; i++) {
    const word = words[i];
    let node = programmingLanguagesTrie;

    for (const char of word) {
      if (!node.children.has(char)) {
        break;
      }
      node = node.children.get(char);
      if (node.isEndOfWord) {
        languages.add(word);
        break;
      }
    }

    for (let j = i + 1; j < words.length; j++) {
      const nextWord = words[j];
      const phrase = word + ' ' + nextWord;

      let node = programmingLanguagesTrie;
      let found = true;

      for (const char of phrase) {
        if (!node.children.has(char)) {
          found = false;
          break;
        }
        node = node.children.get(char);
        if (node.isEndOfWord) {
          languages.add(phrase);
          break;
        }
      }

      if (!found) {
        break;
      }
    }
  }

  return [...languages];
}





function makeWebDecisions(webDevelopment) {
  const decisionMessages = [];

  webDevelopment.forEach(keyword => {
    switch (keyword) {
      case 'website':
        decisionMessages.push("Web development refers to the process of creating websites or web applications. It involves designing, building, and maintaining websites using various technologies such as HTML, CSS, and JavaScript. Web developers use these technologies to create the structure, layout, and functionality of websites. They may also work with server-side technologies and databases to handle data and user interactions. Web development can range from simple static websites to complex web applications with dynamic features and interactive elements.");
        break;
      case 'frontend':
        decisionMessages.push("Frontend development focuses on the client-side of web development. It involves creating the user interface and designing the visual appearance of a website. Frontend developers use HTML, CSS, and JavaScript to build and style web pages, implement interactivity, and ensure a smooth user experience. They need to have a good understanding of web standards, accessibility, and responsive design to create websites that work well across different devices and browsers.");
        break;
      case 'backend':
        decisionMessages.push("Backend development is concerned with the server-side of web development. It involves building the behind-the-scenes functionality of a website or web application. Backend developers work with server-side programming languages such as Node.js, Python, or Java to handle data storage, server-side logic, and integration with databases and external services. They ensure that the frontend and backend components of a web application work together seamlessly to provide the intended functionality.");
        break;
      case 'fullstack':
        decisionMessages.push("Full stack development refers to the combination of both frontend and backend development. Full stack developers are proficient in both client-side and server-side technologies, allowing them to work on all aspects of web development. They can handle both the user interface and the server logic, and are responsible for creating end-to-end web solutions. Full stack developers need to have a broad range of skills and knowledge to develop and maintain complete web applications.");
        break;
      case 'node js':
        decisionMessages.push('node js is a runtime environment for javascript');
        break;
      case 'angular':
        decisionMessages.push('angular js is a javscript frontend framework');
        break;
      default:
        decisionMessages.push("Web development is a broad field that encompasses various aspects of creating websites and web applications. It involves frontend development, backend development, and the integration of different technologies and tools to build functional and visually appealing web solutions.");
    }
  });

  return decisionMessages;
}
//for extracting web classifier keywords
function extractWebKeywords(message) {
  const tokens = message.split(/[ ,.?!]+/);

  const webKeywords = ['website', 'frontend', 'backend', 'fullstack', 'restApi', 'reactjs', 'node js', 'angular'];

  const keywords = tokens.filter(token => webKeywords.includes(token.toLowerCase()));
  return keywords;
}




module.exports.handler = async (event, context) => {
  try {
    const { message, userId } = JSON.parse(event.body);

    console.log('Received message:', message);
    console.log('User ID:', userId);

    const response = await processMessage(message);

    console.log('Response:', response);
    const id = new Date().toISOString(); 
    const params = {
      TableName: tableName,
      Item: {
        id: id,
        message: message,
        response: response,
        userId: userId
      }
    };
    await docClient.put(params).promise();

    console.log('Data added to the database.');

    return {
      statusCode: 200,
      body: JSON.stringify({ id: id, response: response, message: 'successfully added to the DynamoDB database' })
    };
  } catch (err) {
    console.log(err.message);
    return {
      statusCode: 500,
      body: JSON.stringify({ message: err.message })
    };
  }
};


trainClassifier();